import fs from 'node:fs';import path from 'node:path';import {spawnSync} from 'node:child_process';import {timeline} from '../src/timeline.js';
const root=path.resolve(import.meta.dirname,'..');process.chdir(root);
function run(args){const r=spawnSync('ffmpeg',['-y','-loglevel','warning',...args],{stdio:'inherit'});if(r.status!==0)throw Error('ffmpeg failed: '+r.status);}
const clean='preview/submission-picture.mp4',captioned='preview/submission-captioned-picture.mp4',score='preview/score-submission.wav';for(const f of [clean,captioned,score])if(!fs.existsSync(f))throw Error('Missing '+f);
run(['-i',captioned,'-i',score,'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','128k','-metadata','title=TypeParkinson — Congressional App Challenge 2026','-metadata','artist=Atharv Sharma & Pranav Atreya','-movflags','+faststart','-shortest','TypeParkinson-submission.mp4']);
const scenes=timeline('submission'),labels=scenes.map((s,i)=>`[v${i}]`).join(''),alabels=scenes.map((s,i)=>`[a${i}]`).join('');let filters=`[0:v]split=${scenes.length}${labels};[1:a]asplit=${scenes.length}${alabels};`;
for(const [i,s] of scenes.entries()){filters+=`[v${i}]trim=start=${s.start}:end=${s.end},setpts=(PTS-STARTPTS)*${s.p}/${s.s},fps=60[vv${i}];[a${i}]atrim=start=${s.start}:end=${s.end},asetpts=PTS-STARTPTS,atempo=${s.s/s.p}[aa${i}];`;}
filters+=scenes.map((s,i)=>`[vv${i}][aa${i}]`).join('')+`concat=n=${scenes.length}:v=1:a=1[v][a]`;
fs.writeFileSync('preview/presenter-filter.txt',filters);
run(['-i',clean,'-i',score,'-filter_complex_script','preview/presenter-filter.txt','-map','[v]','-map','[a]','-c:v','libx264','-preset','fast','-crf','21','-pix_fmt','yuv420p','-c:a','aac','-b:a','128k','-movflags','+faststart','TypeParkinson-presenter.mp4']);
run(['-i','TypeParkinson-presenter.mp4','-map','0:v:0','-an','-c:v','copy','-movflags','+faststart','TypeParkinson-presenter-silent.mp4']);
fs.copyFileSync(score,'score-submission.wav');
// Preserve a compact procedural soundtrack alongside its reproducible WAV source.
run(['-i',score,'-c:a','aac','-b:a','160k','score-submission.m4a']);
for(const f of ['TypeParkinson-submission.mp4','TypeParkinson-presenter.mp4','TypeParkinson-presenter-silent.mp4'])console.log(f,fs.statSync(f).size);

for(const f of ['TypeParkinson-submission.mp4','TypeParkinson-presenter.mp4','TypeParkinson-presenter-silent.mp4']){if(fs.statSync(f).size>50000000){const probe=spawnSync('ffprobe',['-v','error','-show_entries','format=duration','-of','json',f],{encoding:'utf8'});const d=Number(JSON.parse(probe.stdout).format.duration),bitrate=Math.floor(47000000*8/d-140000),tmp='preview/capped-'+path.basename(f);run(['-i',f,'-c:v','libx264','-preset','fast','-b:v',String(bitrate),'-maxrate',String(Math.round(bitrate*1.5)),'-bufsize',String(bitrate*3),'-c:a','aac','-b:a','128k','-movflags','+faststart',tmp]);fs.renameSync(tmp,f);console.log('Capped',f,fs.statSync(f).size);}}
