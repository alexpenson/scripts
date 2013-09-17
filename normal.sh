#!/bin/bash
sed -e '1s/#/N/g' -e '1s/SNP\tbitfield\t//' | normal.r | sed '1s/^row.names\t//'
