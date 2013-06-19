#!/bin/bash
ref=
samtools mpileup -uf $ref "$@" | bcftools view -vcg -