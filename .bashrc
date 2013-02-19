#############################################
### SETUP
# shopt -s autocd checkjobs 
shopt -s histverify histreedit histappend
export HISTCONTROL=erasedups
export HISTIGNORE="?:??" 
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
#export PROMPT_COMMAND="history -a; history -n; history -r"
export PROMPT_COMMAND="history -a; history -n"
if [[ $(hostname) == *login* ]] ## titan login node
then PS1='\[\033[1;34m\]\h \t \[\033[1;33m\]\w\n\[\033[0m\]  '  ## blue
else 
    PS1='\[\033[1;32m\]\h \t \[\033[1;33m\]\w\n\[\033[0m\]  '  ## green

    # attempt at altscreen
    export TERM=xterm 
    export LESS="-r -+X"
fi

#export TERM=xterm
#export TERM=xterm-noalt
export EDITOR='/usr/bin/emacs -nw'
export VISUAL='/usr/bin/emacs -nw'
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

export scratch=/ifs/scratch/c2b2/rr_lab/$USER
export scripts=$scratch/scripts
export data=/ifs/data/c2b2/rr_lab/$USER
export results=$scratch/Cancer/201211_mds_ng/dna/results

export MATLABROOT=/nfs/apps/matlab/current
export MATLABPATH=$scratch/scripts

export R_HISTFILE=~/.Rhistory

# export PERL5LIB=$PERL5LIB:/ifs/scratch/c2b2/rr_lab/shares/perl_modules
# eval $(perl -I/ifs/scratch/c2b2/rr_lab/shares/perl_modules/lib/perl5 -Mlocal::lib=/ifs/scratch/c2b2/rr_lab/shares/perl_modules)

PATH=/nfs/apps/perl/5.10.0/bin:$PATH
PATH=/nfs/apps/python/2.6.5/bin:$PATH
LD_LIBRARY_PATH=/nfs/apps/python/2.7.2/lib:$LD_LIBRARY_PATH

PATH=$PATH:/nfs/apps/matlab/current/bin
PATH=$PATH:/nfs/apps/R/2.15.1/bin
PATH=$PATH:$scratch/scripts

shares=/ifs/home/c2b2/rr_lab/shares 
PATH=$PATH:${shares}/scripts
PATH=$PATH:${shares}/scripts/savi
PATH=$PATH:${shares}/ncbi-blast-2.2.25+/bin
PATH=$PATH:${shares}/fastx_toolkit/bin PATH=$PATH:${shares}/bin
PATH=$PATH:${shares}/bin/BEDTools-Version-2.16.2/bin
PATH=$PATH:${shares}/bin/Quake/bin PATH=$PATH:${shares}/bin/blat34
PATH=$PATH:${shares}/bin/bowtie2-2.0.2
PATH=$PATH:${shares}/bin/velvet_1.2.03
PATH=$PATH:${shares}/bin/bwa-0.5.9
PATH=$PATH:${shares}/bin/abyss_program/bin
PATH=$PATH:${shares}/bin/trans-ABySS-v1.3.2/bin
PATH=$PATH:${shares}/bin/samtools-0.1.16/bin export PATH
PATH=$PATH:${shares}/bin/FastQC
PATH=$PATH:${shares}/GenomeAnalysisTK-2.3-6-gebbba25
PATH=$PATH:${shares}/bin/picard-tools-1.71
PATH=$PATH:${shares}/bin/cufflinks-2.0.2
PATH=$PATH:/ifs/scratch/c2b2/rr_lab/shares/perl_modules/bin

export AWKPATH=${shares}/awk_scripts

# if [ "$1" == "scratch" ]; then
#     HOME=/ifs/scratch/c2b2/rr_lab/$USER
#     MYHOME=/ifs/home/c2b2/rr_lab/$USER
# else
#     HOME=/ifs/home/c2b2/rr_lab/$USER
#     SCRATCH=/ifs/scratch/c2b2/rr_lab/$USER
# fi

#############################################
### DISPLAY
# nodeid=$( ps -fp $PPID | grep shep | cut -d"-" -f2 )
# if [ "${nodeid}" != "" ]; then
# 	export DISPLAY=$( qstat -j $nodeid | grep DISPLAY | cut -d"=" -f2 | cut -d"," -f1 )
# fi

# if [[ $(hostname) == *login* ]] 
# then echo $DISPLAY > ~/display.dat
# else export DISPLAY=$(<~/display.dat)
# fi

#############################################
### FUNCTIONS
function cur {
    curl $1 -o $(basename $1)
}
alias e='emacs -nw '
#alias e='clear; emacs -nw '
function es {
touch $1
chmod +x $1
clear; emacs -nw $1
}
function ew {
emacs -nw $(which $1)
}
alias matlab='$MATLABROOT/bin/matlab -singleCompThread -nodesktop -nosplash'
alias b="e ~/.bashrc; exec bash"
alias bk="cd -"
function r {
    for i in $*
    do echo -n $(readlink -e $i)" "
    done 
    echo
}
alias tf='screen -X title "$(basename $(pwd))"'
function newest {
    shopt -os noglob
    ls -t1 $* | head -n ${2-1} ## second arg defaults to one
    shopt -ou noglob
}

function q {
    ## send mail on abort
#    if [[ -n $STY ]]; then screen -X title "qrsh"; fi
    qrsh -l mem=${1-2}G,time=${2-8}:: bash -li
}
alias node="while true; do q; sleep 300; done"
function left {
    qstatj=$(qstat -j $JOB_ID)
    echo "$qstatj"
    start=$(echo "$qstatj" | grep submission_time | cut -c28- | xargs -I{} date --utc -d {} +%s)
    echo start $start
    duration=$(echo "$qstatj" | grep -oP 'h_rt=\d+' | cut -d= -f2)
    echo duration $duration
    now=$(date --utc +%s)
    echo now $now
    date --utc -d "@"$(( $now - $start )) +%T
    remain=$(( start + duration - now ))
    echo remain $remain
    date --utc -d "@"$remain +%T
}
function ljoin { 
    local OLDIFS=$IFS
    IFS=${1:?"Missing separator"}; shift
    echo "$*"
    IFS=$OLDIFS
}
alias qst='qstat | tail -n +3 | grep -v QLOGIN | grep -v QRLOGIN'
alias qls='for i in $(qst | cut -c1-7); do jobids=(${jobids[@]} $i); done; export jobids; echo ${jobids[@]}'
alias qlsc='for i in $(qst | cut -c1-7); do echo -n $i,; done; echo'
function w {
    if [[ -n $STY ]]; then screen -X title "watch"; fi
    watch "qstat | tail -n +3 | grep -v QLOGIN | grep -v QRLOGIN | wc -l; qstat | tail -n +3"
}

### email
function em {
    mail -s "$*" $USER < /dev/null > /dev/null
}
alias qm="qalter -m ea"
alias qsdel='cut -f1 -d" " | xargs qdel'
alias qsj='cut -f1 -d" " | xargs -I{} qstat -j {}'

alias sc='echo $DISPLAY>~/display.dat; screen -ADR main_screen'
alias d='export DISPLAY=$(cat ~/display.dat)'

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias .......='cd ../../../../../..'
alias lsn='ls -Gh --color=never'
alias ls='ls -h --color'
alias ll='ls -l'
alias lt='ls -ltr'
alias llu="ll;'du' -sh"
# function tr {
#     tree --dirsfirst -ChFupDaLg ${1-1}
# }
function big {
#http://www.earthinfo.org/linux-disk-usage-sorted-by-size-and-human-readable/
    for i in $*
      do du -sk $i
    done | sort -n | while read size fname
      do for unit in k M G T P E Z Y
	do if [ $size -lt 1024 ]
	    then echo -e "${size}${unit}\\t${fname}"
	    break
	fi
	size=$((size/1024))
      done
    done
}

function ediff {
    emacs -nw --eval '(ediff-files "'$1'" "'$2'")'
}

# function calc {
#     bc << EOF
# scale=4 
# $@ 
# quit 
# EOF 
# }
# alias calc='noglob calc' 

#############################################
## REFERENCES
export ref_bwa_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bwa/genome/hg19.fa
export ref_bowtie_genome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/genome/hg19
export ref_bwa_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bwa/transcriptome/transcriptome_fasta
export ref_bowtie_transcriptome=/ifs/scratch/c2b2/rr_lab/shares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta

export SETUP=bash_profile

unset TZ

# remove duplicates in PATH, but keep the order
PATH="$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')"
PATH="${PATH%:}"    # remove trailing colon
export PATH

