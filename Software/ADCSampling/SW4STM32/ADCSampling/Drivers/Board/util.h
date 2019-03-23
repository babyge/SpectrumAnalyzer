#ifndef IOX_UTIL_H_
#define IOX_UTIL_H_

#include <stdint.h>

static inline int32_t util_sign_extend_32(int32_t x, uint16_t bits) {
	int32_t m = 1 << (bits - 1);
	return (x ^ m) - m;
}

static inline char util_nibble_to_hex_char(uint8_t n) {
	return n < 10 ? n + '0' : n + 'A' - 0x0A;
}

static inline uint8_t util_hex_to_nibble(char c) {
	return c <= '9' ? c - '0' : c - 'A' + 0x0A;
}

// returns date/time in unix timestamp
uint32_t unixtime(int year, int month, int day,
              int hour, int minute, int sec);

static inline uint16_t htons(uint16_t hostshort) {
	return ((hostshort & 0xFF00) >> 8) | ((hostshort & 0x00FF) << 8);
}

static inline uint16_t ntohs(uint16_t netshort) {
	return ((netshort & 0xFF00) >> 8) | ((netshort & 0x00FF) << 8);
}

static inline uint32_t htonl(uint32_t hostlong) {
	return ((hostlong & 0xFF000000) >> 24) | ((hostlong & 0x00FF0000) >> 8)
			| ((hostlong & 0x0000FF00) << 8) | ((hostlong & 0x000000FF) << 24);
}

static inline uint32_t ntohl(uint32_t netlong) {
	return ((netlong & 0xFF000000) >> 24) | ((netlong & 0x00FF0000) >> 8)
			| ((netlong & 0x0000FF00) << 8) | ((netlong & 0x000000FF) << 24);
}

#endif
