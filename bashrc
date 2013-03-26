#############################################
### SETUP
# shopt -s autocd checkjobs 
shopt -s histverify histreedit histappend
export HISTCONTROL=erasedups
export HISTIGNORE="?:??" 
export HISTSIZE=100000
export HISTFILESIZE=100000
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
export PROMPT_COMMAND="history -a; history -n"
if [[ $(hostname) == *login* ]] ## titan login node
then PS1='\[\033[1;34m\]\h \t \[\033[1;33m\]\w\n\[\033[0m\]  '  ## blue
else 
    PS1='\[\033[1;32m\]\h \t \[\033[1;33m\]\w\n\[\033[0m\]  '  ## green

    # attempt at altscreen
    export TERM=xterm 
    export LESS="-r +X"
fi

export EDITOR='/usr/bin/emacs -nw'
export VISUAL='/usr/bin/emacs -nw'
export WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'

export SETUP=bash_profile

### FOR CORRECT TIME ON THE CLUSTER
unset TZ

#############################################
### PATHS
export sshares=/ifs/scratch/c2b2/rr_lab/shares 
export shares=/ifs/home/c2b2/rr_lab/shares 
export scratch=/ifs/scratch/c2b2/rr_lab/$USER
export scripts=$scratch/scripts
export logs=$scratch/submit/logs
export data=/ifs/data/c2b2/rr_lab/$USER
export results=$scratch/Cancer/201211_mds_ng/dna/results

export TMP=$scratch/tmp
export TMPDIR=$scratch/tmp

### AWK
PATH=$sshares/bioawk:$PATH
export AWKPATH=${shares}/awk_scripts

### PERL
PATH=/nfs/apps/perl/5.16.2/bin:$PATH
PATH=$PATH:$sshares/perl_modules/bin
export PERL_MM_USE_DEFAULT=1
export PERL5LIB=$PERL5LIB:$sshares/perl_modules
export PERL5LIB=$PERL5LIB:$sshares/perl_modules/lib/perl5
export PERL5LIB=$PERL5LIB:$sshares/perl_modules/lib/perl5/x86_64-linux-thread-multi
# eval $(perl -I/ifs/scratch/c2b2/rr_lab/shares/perl_modules/lib/perl5 -Mlocal::lib=/ifs/scratch/c2b2/rr_lab/shares/perl_modules)

### PYTHON
PATH=/nfs/apps/python/2.6.5/bin:$PATH
LD_LIBRARY_PATH=/nfs/apps/python/2.6.5/lib:$LD_LIBRARY_PATH

### MATLAB
PATH=$PATH:/nfs/apps/matlab/current/bin
export MATLABROOT=/nfs/apps/matlab/current
export MATLABPATH=$scratch/scripts

### R
PATH=$PATH:/nfs/apps/R/2.15.1/bin
export R_HISTFILE=~/.Rhistory

PATH=$PATH:$scratch/scripts
PATH=$PATH:${shares}/scripts
PATH=$PATH:${shares}/scripts/savi
PATH=$PATH:${shares}/ncbi-blast-2.2.25+/bin
PATH=$PATH:${shares}/fastx_toolkit/bin 
PATH=$PATH:${shares}/bin
PATH=$PATH:${shares}/bin/BEDTools-Version-2.16.2/bin
PATH=$PATH:${shares}/bin/Quake/bin 
PATH=$PATH:${shares}/bin/blat34
PATH=$PATH:${shares}/bin/bowtie2-2.0.2
PATH=$PATH:${shares}/bin/velvet_1.2.03
PATH=$PATH:${shares}/bin/bwa-0.5.9
PATH=$PATH:${shares}/bin/abyss_program/bin
PATH=$PATH:${shares}/bin/trans-ABySS-v1.3.2/bin
PATH=$PATH:${shares}/bin/samtools-0.1.16/bin 
PATH=$PATH:${shares}/bin/FastQC
PATH=$PATH:${shares}/bin/picard-tools-1.71
PATH=$PATH:${shares}/bin/cufflinks-2.0.2
PATH=$PATH:${shares}/bin/Ray-v2.1.0_program

### remove duplicates in PATH, but keep the order
PATH="$(printf "%s" "${PATH}" | /usr/bin/awk -v RS=: -v ORS=: '!($0 in a) {a[$0]; print}')"
PATH="${PATH%:}"    # remove trailing colon
export PATH

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
alias remake="make clean; make"
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
    for i in $*; do 
	echo -n $(readlink -e $i)" "
    done 
    echo
}
alias ct="column -t"
alias ctt="column -ts$'\t'"
alias tf='screen -X title "$(basename $(pwd))"'
function newest {
    shopt -os noglob
    ls -t1 $* | head -n ${2-1} ## second arg defaults to one
    shopt -ou noglob
}

function qs {
    mem=$1; shift
    hours=$1; shift
    message=$(qsub -l mem=${mem}G,time=${hours}:: "$@")
    echo $message
    jid=$( echo $message | cut -f3 -d" " )
}
function bs {
    mem=$1; shift
    hours=$1; shift
    message=$(qsub -b y -j n -l mem=${mem}G,time=${hours}:: "$@")
    echo $message
    jid=$( echo $message | cut -f3 -d" " )
}
function qsm {
    mem=$1; shift
    hours=$1; shift
    message=$(qsub -m ea -l mem=${mem}G,time=${hours}:: "$@")
    echo $message
    echo "Email will be sent"
    jid=$( echo $message | cut -f3 -d" " )
}
function bsm {
    mem=$1; shift
    hours=$1; shift
    message=$(qsub -m ea -b y -j n -l mem=${mem}G,time=${hours}:: "$@")
    echo $message
    echo "Email will be sent"
    jid=$( echo $message | cut -f3 -d" " )
}

function q {
    ## send mail on abort
    # if [[ -n $STY ]]; then screen -X title "qrsh"; fi
    qrsh -l mem=${1-2}G,time=${2-8}::
}
function node {
    while true; do 
	q "$@"
	sleep 300
    done
}
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
    watch "echo -ne 'Njobs:\t\t'; qstat | tail -n +3 | grep -v QLOGIN | grep -v QRLOGIN | wc -l; \
echo -ne 'Running:\t'; qstat | tail -n +3 | grep -v QLOGIN | grep -v QRLOGIN | grep '  r  ' | wc -l; \
qstat | tail -n +3"
}

### email
function em {
    mail -s "$*" $USER < /dev/null > /dev/null
}
alias qm="qalter -m ea"
alias qsdel='cut -c1-7 | xargs qdel'
alias qsj='cut -c1-7 | xargs -I{} qstat -j {}'

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
export ref_bwa_genome=$sshares/ref/hg19/bwa/genome/hg19
export ref_bowtie_genome=$sshares/ref/hg19/bowtie2/genome/hg19
export ref_bwa_transcriptome=$sshares/ref/hg19/bwa/transcriptome/transcriptome_fasta
export ref_bowtie_transcriptome=$sshares/ref/hg19/bowtie2/transcriptome/transcriptome_fasta
export ref_samtools_genome=$sshares/ref/hg19/samtools_faidx/hg19.fa
export ref_blast_human=$sshares/ref/hg19/blast_plus/genome/db
export ref_blast_nt=$sshares/ref/blastdb/nt/nt


#for vfs
#export PATH=/nfs/apps/perl/5.16.2/bin:/nfs/apps/blast/2.2.20/bin:/nfs/apps/python/2.6.5/bin:/nfs/apps/perl/5.10.0/bin:/opt/gridengine/bin/lx24-amd64:/usr/lib64/qt-3.3/bin:/usr/kerberos/bin:/usr/lib64/ccache:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/OFED/1.5.2/bin:/opt/OFED/1.5.2/sbin:/nfs/apps/matlab/current/bin:/nfs/apps/R/2.15.1/bin:/ifs/scratch/c2b2/rr_lab/avp2106/scripts:/ifs/home/c2b2/rr_lab/shares/scripts:/ifs/home/c2b2/rr_lab/shares/scripts/savi:/ifs/home/c2b2/rr_lab/shares/ncbi-blast-2.2.25+/bin:/ifs/home/c2b2/rr_lab/shares/fastx_toolkit/bin:/ifs/home/c2b2/rr_lab/shares/bin:/ifs/home/c2b2/rr_lab/shares/bin/BEDTools-Version-2.16.2/bin:/ifs/home/c2b2/rr_lab/shares/bin/Quake/bin:/ifs/home/c2b2/rr_lab/shares/bin/blat34:/ifs/home/c2b2/rr_lab/shares/bin/bowtie2-2.0.2:/ifs/home/c2b2/rr_lab/shares/bin/velvet_1.2.03:/ifs/home/c2b2/rr_lab/shares/bin/bwa-0.5.9:/ifs/home/c2b2/rr_lab/shares/bin/abyss_program/bin:/ifs/home/c2b2/rr_lab/shares/bin/trans-ABySS-v1.3.2/bin:/ifs/home/c2b2/rr_lab/shares/bin/samtools-0.1.16/bin:/ifs/home/c2b2/rr_lab/shares/bin/FastQC:/ifs/home/c2b2/rr_lab/shares/bin/picard-tools-1.71:/ifs/home/c2b2/rr_lab/shares/bin/cufflinks-2.0.2:/ifs/home/c2b2/rr_lab/shares/bin/Ray-v2.1.0_program:/ifs/scratch/c2b2/rr_lab/shares/perl_modules/bin:/ifs/scratch/c2b2/rr_lab/shares/ssake_v3-8:/ifs/scratch/c2b2/rr_lab/shares/CAP3

