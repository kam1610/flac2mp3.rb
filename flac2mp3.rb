#!/usr/bin/ruby

# flac2mp3.rb --- convert flac files to mp3 files using muitlple processes.
#
# Copyright 2017 kam1610
# Author: kam1610 <kam1610@gmail.com>
#
# This software is released under the MIT License.
# http://opensource.org/licenses/mit-license.php

require("open3");

cmd= "flac --decode --stdout " +
     "\"_inFile_\"  |  " +
     "/opt/src/lame-3.99.5/frontend/lame " +
     "-V 5 -b 128 " +
     "- " +
     "\"_outFile_\"";
maxProcNum   = 4;
coreUseFlag  = [];
procFileName = [];
myStdIn      = [];
myStdOut     = [];
myStdErr     = [];
myWaitThr    = [];
0.upto(maxProcNum-1){|i|
  coreUseFlag [i]= false;
  procFileName[i]= "";
  myStdIn     [i]= nil;
  myStdOut    [i]= nil;
  myStdErr    [i]= nil;
  myWaitThr   [i]= nil;
}
files= [];
dstDir= "./";

printf("proc for files: \n");
if( ARGV.length == 0 )
  Dir::glob("*.flac"){|f|
    files.push(f);
    printf("  %s\n", f);
  }
else if( ARGV.length == 1 )
  dstDir= ARGV[0];
  while (str= STDIN.gets)
    break if (str.chomp() == ".")
    files.push(str.chomp());
  end
else
  exit(0);
end

unless( Dir.exist?( dstDir ) )
  Dir.mkdir( dstDir );
end

totalFileNum = files.size();
finFileNum   = 0;

controllerThreadState= true;

# controller thread ########################################
Thread.fork {
  while(true)
    # assign one process
    cix= coreUseFlag.index(false)
    if( cix != nil )
      if(files.size() > 0)
        # raise proccess
        fileName= files.pop();
        cmdbuf= cmd.gsub("_inFile_", fileName );

        fileName= dstDir +
                  File.basename(fileName.sub(/\.flac$/, ".mp3"));
        cmdbuf= cmdbuf.sub("_outFile_", fileName);

        # printf(":::: command :::: %s\n", cmdbuf);
        # printf(":::: run : %s\n", fileName);
        myStdIn[cix],
        myStdOut[cix],
        myStdErr[cix],
        myWaitThr[cix] =
        *Open3.popen3( cmdbuf );
        # check flag
        coreUseFlag[cix] = true;
        procFileName[cix]= fileName;
      else
        # printf("no more target file\n");
      end
    else
      # printf("no empty slot.\n");
    end

    # check wait thread
    aliveThread= false;
    0.upto(myWaitThr.size()-1){|i|
      if(myWaitThr[i] != nil)
        aliveThread= true;

        begin
          # printf("%s\n", myStdOut[i].read_nonblock() );
        rescue
          # printf("no buf\n");
        end

        if(myWaitThr[i].alive? == false)
          coreUseFlag[i]= false;
          finFileNum+= 1;
          printf( ">>>> file[%d/%d]: %s \n  is done\n",
                  finFileNum, totalFileNum, procFileName[i]);
          myStdOut[i].close();
          myStdErr[i].close();
          myStdIn[i].close();
          myWaitThr[i] = nil;
        end
      else
        # printf("myWaithThr[%d] is empty\n", i)
      end
    }

    # myWaitThr is all nil and
    # no more file?
    if((aliveThread == false) &
       (files.size() == 0))
      break;
    end

    # output stream
    sleep(0.2);
  end

  controllerThreadState= false;
}

# wait for controller thread
while(true)
  sleep(0.2);
  if(controllerThreadState == false)
    break;
  end
end
