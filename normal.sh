#!/bin/bash
sed '1s/#/N/g' | normal.r | sed '1s/^row.names\t//'
