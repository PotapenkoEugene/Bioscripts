#!/bin/bash
# Convert sam to bam and discard unmapped reads
for i in *.sam; name = $(echo $i | rev | cut -d . -f 2- | rev) ; samtools view -F 4 -b $i > $name.bam ; samtools sort $name.bam > $name.sort.bam ; samtools index $name.sort.bam ; done
# можно добавить удаление файлов промежуточных, когда все будет работать точно
