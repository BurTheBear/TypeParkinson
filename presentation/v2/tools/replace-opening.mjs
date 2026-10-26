// Deadline revision: preserve the finished exercise shots while rendering only
// the changed first 30 seconds at the original 1080p60/four-sample quality.
import fs from 'node:fs';import path from 'node:path';import {spawnSync} from 'node:child_process';
process.chdir(path.resolve(import.meta.dirname,'..'));
for(const f of ['preview/keyboard-intro-picture.mp4','preview/showcase-before-keyboard.mp4'])if(!fs.existsSync(f))throw Error('Missing '+f);
const filter='[0:v]trim=duration=30,setpts=PTS-STARTPTS[a];[1:v]trim=start=30:end=45,setpts=PTS-STARTPTS[b];[a][b]concat=n=2:v=1:a=0,scale=out_range=tv,format=yuv420p[v]';
const output='preview/showcase-keyboard-combined.mp4';const result=spawnSync('ffmpeg',['-y','-loglevel','error','-i','preview/keyboard-intro-picture.mp4','-i','preview/showcase-before-keyboard.mp4','-filter_complex',filter,'-map','[v]','-an','-r','60','-color_range','tv','-c:v','libx264','-preset','fast','-crf','19','-movflags','+faststart',output],{stdio:'inherit'});
if(result.status!==0)throw Error('Opening replacement failed');fs.renameSync(output,'preview/showcase-picture.mp4');console.log('Corrected opening joined to the preserved exercise footage');
