
/* Find how deeply inside an .RPM the real data is */
/* kept, and report the offset in bytes */

/* Wouldn't it be a lot more sane if we could just untar these things? */

#ifndef _GNU_SOURCE
# define _GNU_SOURCE
#endif

#include <stdint.h>
#include <stdio.h>
#include <string.h>

#ifndef ARRAY_SIZE
# define ARRAY_SIZE(a) (sizeof(a) / sizeof((a)[0]))
#endif
#ifndef BUFSIZ
# define BUFSIZ 8192
#endif

#if !defined(__GLIBC__)
static void *rp_memmem(const void *buf, size_t buflen, const void *pattern, size_t len)
{
	char *bf = (char *)buf, *pt = (char *)pattern, *p = bf;

	while (len <= (buflen - (p - bf))) {
		if (NULL != (p = memchr(p, (int)(*pt), buflen - (p - bf)))) {
			if (0 == memcmp(p, pattern, len))
				return p;
			else
				++p;
		}
		else
			break;
	}
	return NULL;
}
#define memmem(a,b,c,d) rp_memmem(a,b,c,d)
#endif

typedef struct {
	const char *type;
	const unsigned char *magic;
	const size_t len;
} magic_t;

/* LZMA is some fuzzy crap */
int is_magic_lzma(const char *buf)
{
	const unsigned char *ubuf = (const void *)buf;
	return (ubuf[0] == 0x5d && ubuf[4] < 0x20) &&
		(!memcmp(buf + 10, "\x00\x00\x00", 3) ||
		 !memcmp(buf +  5, "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", 8));
}
#define magic_lzma_len 13

static const unsigned char magic_gzip[]  = { '\037', '\213', '\010' };
static const unsigned char magic_bzip2[] = { 'B', 'Z', 'h' };
static const unsigned char magic_xz[]    = { 0xFD, '7', 'z', 'X', 'Z', 0x00 };
static const unsigned char magic_zstd[]  = { 0x28, 0xB5, 0x2F, 0xFD };
static const magic_t magics[] = {
#define DECLARE_MAGIC_T(t) { .type = #t, .magic = magic_##t, .len = sizeof(magic_##t), },
	DECLARE_MAGIC_T(gzip)
	DECLARE_MAGIC_T(bzip2)
	DECLARE_MAGIC_T(xz)
	DECLARE_MAGIC_T(zstd)
#undef DECLARE_MAGIC_T
};
#define MAGIC_SIZE_MIN 3
#define MAGIC_SIZE_MAX 13

static int show_magic;

static int magic_finish(const char *magic, size_t offset)
{
	if (show_magic)
		printf("%s ", magic);
	printf("%zu\n", offset);
	return 0;
}

int main(int argc, char *argv[])
{
	size_t i, read_cnt, offset, left, lzma_offset;
	FILE *fp = stdin;
	char p[BUFSIZ];

	if (argc == 2 && !strcmp(argv[1], "-v")) {
		show_magic = 1;
		--argc;
	}

	if (argc != 1) {
		puts("Usage: rpmoffset < rpmfile");
		return 1;
	}
	/* fp = fopen(argv[1], "r"); */

	lzma_offset = 0;
	offset = left = 0;
	while (1) {
		read_cnt = fread(p + left, 1, sizeof(p) - left, fp);
		if (read_cnt + left < MAGIC_SIZE_MIN)
			break;

		for (i = 0; i < ARRAY_SIZE(magics); ++i) {
			const char *needle;

			if (read_cnt + left < magics[i].len)
				continue;

			needle = memmem(p, sizeof(p), magics[i].magic, magics[i].len);
			if (needle)
				return magic_finish(magics[i].type, offset + (needle - p));
		}

		/* Scan for LZMA magic, but don't return yet ... */
		if (!lzma_offset && read_cnt + left >= magic_lzma_len) {
			for (i = 0; i <= read_cnt + left - magic_lzma_len; ++i)
				if (is_magic_lzma(p + i)) {
					lzma_offset = offset + i;
					break;
				}
		}

		memmove(p, p + left + read_cnt - MAGIC_SIZE_MIN + 1, MAGIC_SIZE_MIN - 1);

		offset += read_cnt;
		if (left == 0) {
			offset -= MAGIC_SIZE_MIN - 1;
			left = MAGIC_SIZE_MIN - 1;
		}
	}

	/* Delay till the end for LZMA archives since it is too fuzzy */
	if (lzma_offset)
		return magic_finish("lzma", lzma_offset);

	if (ferror(stdin))
		perror(argv[0]);

	return 1;
}
