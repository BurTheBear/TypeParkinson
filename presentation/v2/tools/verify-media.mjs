import fs from 'node:fs';import path from 'node:path';import crypto from 'node:crypto';import {spawnSync} from 'node:child_process';import {captionCues} from '../src/timeline.js';
const root=path.resolve(import.meta.dirname,'..');process.chdir(root);
const expected=[['TypeParkinson-intro-30s.mp4',30,true],['TypeParkinson-showcase-45s.mp4',45,true],['TypeParkinson-showcase-silent.mp4',45,false],['TypeParkinson-presenter.mp4',112,true],['TypeParkinson-presenter-silent.mp4',112,false],['TypeParkinson-submission.mp4',168,true]];
const report={checkedAt:new Date().toISOString(),playerSHA256:crypto.createHash('sha256').update(fs.readFileSync('animation.html')).digest('hex'),files:[]};
for(const [file,duration,audio] of expected){
 const probe=spawnSync('ffprobe',['-v','error','-show_entries','format=duration,size:stream=codec_name,codec_type,width,height,r_frame_rate,nb_frames,pix_fmt','-of','json',file],{encoding:'utf8'});if(probe.status!==0)throw Error(file+': probe failed');
 const data=JSON.parse(probe.stdout),video=data.streams.find(s=>s.codec_type==='video'),sound=data.streams.find(s=>s.codec_type==='audio');
 if(video.codec_name!=='h264'||video.width!==1920||video.height!==1080||video.r_frame_rate!=='60/1'||video.pix_fmt!=='yuv420p')throw Error(file+': wrong video format');
 if(Math.abs(Number(data.format.duration)-duration)>.1||Number(data.format.size)>=50000000)throw Error(file+': duration/size outside delivery limit');
 if(Boolean(sound)!==audio)throw Error(file+': wrong audio presence');
 const decode=spawnSync('ffmpeg',['-v','error','-i',file,'-f','null','-'],{encoding:'utf8'});if(decode.status!==0||decode.stderr.trim())throw Error(file+': decode errors '+decode.stderr);
 report.files.push({file,duration:Number(data.format.duration),bytes:Number(data.format.size),video,audio:sound?.codec_name||null,fullDecode:true});
 console.log(file,report.files.at(-1).duration,report.files.at(-1).bytes,'full decode PASS');
}
const blocks=fs.readFileSync('TypeParkinson-submission.srt','utf8').trim().split(/\n\s*\n/),cues=captionCues();const seconds=s=>{const [h,m,n]=s.replace(',','.').split(':').map(Number);return h*3600+m*60+n;};
if(blocks.length!==cues.length)throw Error('Wrong SRT count');
blocks.forEach((block,i)=>{const lines=block.split('\n'),times=lines[1].split(' --> ').map(seconds),cue=cues[i];if(lines.slice(2).join(' ')!==cue.text||Math.abs(times[0]-cue.start)>.001||Math.abs(times[1]-cue.end)>.001)throw Error('SRT mismatch '+i);});
report.srt={cues:cues.length,endsAt:cues.at(-1).end,matchesNarration:true};report.passed=true;fs.writeFileSync('reviews/media-validation.json',JSON.stringify(report,null,2)+'\n');console.log('All media and long-film SRT checks PASS');
