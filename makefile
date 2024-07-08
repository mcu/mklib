###############################################################################
.PHONY: all build clean

CCDIR        = ../../../tools/bin
CORE         = -mcpu=cortex-m7 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard
OPTIMIZATION = -O0 -g0
DEFINITIONS  =

###############################################################################

OUTDIR  := build
LIBNAME := $(notdir $(shell pwd))
DIRS    := $(shell ls -R . | grep : | sed 's/://')

ASSOURCES := $(wildcard $(addsuffix /*.s, $(DIRS)))
CSOURCES  := $(wildcard $(addsuffix /*.c, $(DIRS)))

OBJECTS := $(addprefix $(OUTDIR)/, $(ASSOURCES:.s=.o))
OBJECTS += $(addprefix $(OUTDIR)/, $(CSOURCES:.c=.o))

HEADERS := $(addprefix -I", $(addsuffix ", $(DIRS)))

###############################################################################

  AR = $(CCDIR)/arm-none-eabi-ar
  CC = $(CCDIR)/arm-none-eabi-gcc
 CXX = $(CCDIR)/arm-none-eabi-g++
SIZE = $(CCDIR)/arm-none-eabi-size

ASFLAGS = $(CORE) -x assembler-with-cpp

CFLAGS = -std=gnu17 $(CORE) $(OPTIMIZATION) $(DEFINITIONS) $(HEADERS) \
         -ffunction-sections -fdata-sections -fcyclomatic-complexity \
         --specs=nano.specs -Wall -Wextra

###############################################################################

all: build

build: $(OUTDIR)/$(LIBNAME).a \
       $(OUTDIR)/$(LIBNAME).siz

$(OUTDIR)/$(LIBNAME).a: $(OBJECTS)
	@echo arc: $(@F)
	@mkdir -p $(@D)
	@$(AR) rc $@ $^

$(OUTDIR)/$(LIBNAME).siz: $(OUTDIR)/$(LIBNAME).a
	@$(SIZE) --format=berkeley $(OUTDIR)/$(LIBNAME).a

$(OUTDIR)/%.o: %.s
	@echo gcc: $(@F)
	@mkdir -p $(@D)
	@$(CC) -c $(ASFLAGS) '$<' -o '$@'

$(OUTDIR)/%.o: %.c
	@echo gcc: $(@F)
	@mkdir -p $(@D)
	@$(CC) -c $(CFLAGS) '$<' -o '$@'

clean:
	rm -rf $(OUTDIR)

###############################################################################
