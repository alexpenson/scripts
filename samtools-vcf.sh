#!/bin/bash
ref=$1; shift
samtools mpileup -uf $ref "$@" | bcftools view -vcg -