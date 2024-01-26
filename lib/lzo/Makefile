ccflags-y += -mllvm -inline-threshold=15000
ccflags-y += -mllvm -inlinehint-threshold=10000

lzo_compress-objs := lzo1x_compress.o
lzo_decompress-objs := lzo1x_decompress_safe.o

obj-$(CONFIG_LZO_COMPRESS) += lzo_compress.o
obj-$(CONFIG_LZO_DECOMPRESS) += lzo_decompress.o
