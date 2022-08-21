#include <stddef.h>
#include <stdint.h>
#include "heap.h"
#include "kmalloc.h"

extern char _kernel_end;

struct HEAP __kheap_kmalloc = {
    .start = (size_t)((uintptr_t)&_kernel_end) + 4096,
    .ptr = 0,
    .size = 1024*1024*16,  // max heap size 16MB
    .flag = 0
};

struct KMALLOC_FREENODE {
    struct KMALLOC_FREENODE* next;
    size_t size;
};
struct KMALLOC_FREELIST {
    struct KMALLOC_FREENODE node;
};
// -------------------------------------------------
struct KMALLOC_FREELIST __kmalloc_64    = { .node = { .next = 0, .size = 0} };
struct KMALLOC_FREELIST __kmalloc_512   = { .node = { .next = 0, .size = 0} };
struct KMALLOC_FREELIST __kmalloc_1024  = { .node = { .next = 0, .size = 0} };
struct KMALLOC_FREELIST __kmalloc_large = { .node = { .next = 0, .size = 0} };
// -------------------------------------------------
void* kmalloc(size_t size) {
    struct KMALLOC_FREELIST *list;
    struct KMALLOC_FREENODE *node = 0;
    struct KMALLOC_FREENODE *parent;
    size = (((size + 16 +15) >> 4) << 4);
    if (size <= 64) {
        list = &__kmalloc_64;
        size = 64;
    } else if (size <= 512) {
        list = &__kmalloc_512;
        size = 512;
    } else if (size <= 1024) {
        list = &__kmalloc_1024;
        size = 1024;
    } else {
        list = &__kmalloc_large;
    }
    if (size <= 1024) {
        if ((node=list->node.next) != 0) {
            list->node.next = node->next;
        }
     } else {
        for (parent=&list->node; ; parent=node) {
            if ((node=parent->next) == 0) break;
            if (node->size >= size) {
                parent->next = node->next;
                break;
            }
        }
    }
    if (node == 0) {
        node = (struct KMALLOC_FREENODE*)heap_alloc(&__kheap_kmalloc, size);
        if (node == 0) return NULL;
        node->size = size;
    }
    return (void*) ((char*)node + 16);
}
void kfree(const void* ptr) {
    struct KMALLOC_FREELIST* list;
    struct KMALLOC_FREENODE* node;
    if (ptr == NULL) return;
    node = (struct KMALLOC_FREENODE*)((size_t)ptr - 16);
    if (node->size <= 64) {
        list = &__kmalloc_64;
    } else if (node->size <= 512) {
        list = &__kmalloc_512;
    } else if (node->size <= 1024) {
        list = &__kmalloc_1024;
    } else {
        list = &__kmalloc_large;
    }
    node->next = list->node.next;
    list->node.next = node;
}
