import fs from 'node:fs';import path from 'node:path';import {spawnSync} from 'node:child_process';
const root=path.resolve(import.meta.dirname,'..');process.chdir(root);
const run=args=>{const r=spawnSync('ffmpeg',['-y','-loglevel','warning',...args],{stdio:'inherit'});if(r.status!==0)throw Error('ffmpeg failed');};
for(const f of ['preview/showcase-picture.mp4','preview/score-showcase.wav'])if(!fs.existsSync(f))throw Error('Missing '+f);
// JPEG intermediates carry full-range colour. Convert explicitly to TV-range
// yuv420p for reliable hardware/browser decoding instead of tagging yuvj420p.
run(['-i','preview/showcase-picture.mp4','-i','preview/score-showcase.wav','-map','0:v:0','-map','1:a:0','-vf','scale=out_range=tv,format=yuv420p','-color_range','tv','-c:v','libx264','-preset','fast','-crf','21','-c:a','aac','-b:a','128k','-shortest','-metadata','title=TypeParkinson — 45-second exercise showcase','-metadata','artist=Atharv Sharma & Pranav Atreya','-movflags','+faststart','TypeParkinson-showcase-45s.mp4']);
run(['-i','TypeParkinson-showcase-45s.mp4','-t','30','-map','0:v:0','-map','0:a:0','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p','-color_range','tv','-af','afade=t=out:st=28:d=2','-c:a','aac','-b:a','128k','-movflags','+faststart','TypeParkinson-intro-30s.mp4']);
run(['-i','TypeParkinson-showcase-45s.mp4','-map','0:v:0','-c:v','copy','-an','-movflags','+faststart','TypeParkinson-showcase-silent.mp4']);
console.log('Revised 30s intro, 45s exercise showcase and silent showcase ready.');
