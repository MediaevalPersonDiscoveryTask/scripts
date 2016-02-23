#!/bin/bash

#$ -N MP4
#$ -S /bin/bash
#$ -o /vol/work1/bredin/mediaeval/PersonDiscovery2016/logs
#$ -e /vol/work1/bredin/mediaeval/PersonDiscovery2016/logs
#$ -v LD_LIBRARY_PATH
#$ -v PATH

ORIGINAL="/vol/corpora5/mediaeval/INA/LAffaireSnowden"
PROCESSED="/vol/work1/bredin/mediaeval/PersonDiscovery2016/INA/LAffaireSnowden"

if [ -n "${SGE_TASK_ID+x}" ]; then

    STEP=${SGE_TASK_LAST}-${SGE_TASK_FIRST}+1
    FIRST=${SGE_TASK_ID}-${SGE_TASK_FIRST}+1

    LIST=$1
    
    NUMBER=`wc -l $LIST|awk '{print $1}'`

    for (( f=$FIRST; f<=$NUMBER; f=f+$STEP ))
    do

      RELATIVE=$(head -n ${f} ${LIST} |tail -n 1)
      
      mkdir -p `dirname $PROCESSED/$RELATIVE.mp4`
      ffmpeg -y -i $ORIGINAL/$RELATIVE -vcodec libx264 -preset medium -acodec copy $PROCESSED/$RELATIVE.mp4
      ffmpeg -y -i $PROCESSED/$RELATIVE.mp4 -ac 1 $PROCESSED/$RELATIVE.raw.wav
      sndfile-resample -to 16000 -c 0 $PROCESSED/$RELATIVE.raw.wav $PROCESSED/$RELATIVE.wav
      rm $PROCESSED/$RELATIVE.raw.wav

    done
else
    echo "What? $ORIGINAL/{VIDEO} ==> H264 (same resolution) $PROCESSED/{VIDEO}.mp4"
    echo "                        ==> WAV 16kHz $PROCESSED/{VIDEO}.wav"
    echo "for each {VIDEO} in file MP4.listing"
    echo "How? qsub -t 1-NSPLIT `basename $0` MP4.listing"
fi

