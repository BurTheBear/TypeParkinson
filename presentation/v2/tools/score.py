#!/usr/bin/env python3
"""Deterministic procedural score; fallback when long browser audio export stalls."""
import array,math,random,wave,json,pathlib
ROOT=pathlib.Path(__file__).resolve().parents[1]
RATE=48000;DURATION=168;N=RATE*DURATION
left=array.array('f',[0])*N;right=array.array('f',[0])*N
roots=[130.8128,110,146.8324,97.9989]
for block in range(math.ceil(DURATION/16)):
 start=block*16;end=min(DURATION,start+18);freq=roots[block%4]
 for i in range(start*RATE,int(end*RATE)):
  t=i/RATE;local=t-start;envelope=min(1,local/1.6)*max(0,min(1,(end-t)/2.0))
  v=(.022*math.sin(math.tau*freq*t)+.010*math.sin(math.tau*freq*1.5*t)+.006*math.sin(math.tau*freq*2.5*t))*envelope
  left[i]+=v;right[i]+=v*.97
 print('pad',block,flush=True)
starts=[0,10,25,37,55,77,96,112,132,149,158];rng=random.Random(417)
for start in starts[1:]:
 length=1.6;begin=max(0,start-.4);filtered=0
 for j in range(int(length*RATE)):
  index=int(begin*RATE)+j
  if index>=N:break
  x=j/(length*RATE);filtered=.9*filtered+.1*(rng.random()*2-1);v=filtered*.08*math.sin(math.pi*x)**2;pan=x*.9-.45
  left[index]+=v*(1-pan);right[index]+=v*(1+pan)
for scene in [0,4,6,7,8]:
 for k in range(5):
  start=starts[scene]+1+k*.42
  for j in range(int(.085*RATE)):
   t=j/RATE;index=int(start*RATE)+j;v=(.055*math.sin(math.tau*(260+k*23)*t)+.016*(rng.random()*2-1))*math.exp(-t*65)*min(1,t/.003)
   if index<N:left[index]+=v;right[index]+=v
pcm=array.array('h')
for i in range(N):
 t=i/RATE;fade=min(1,t/2)*min(1,max(0,(DURATION-t)/4))
 pcm.append(int(max(-1,min(1,left[i]*fade))*32767));pcm.append(int(max(-1,min(1,right[i]*fade))*32767))
out=ROOT/'preview/score-submission.wav'
with wave.open(str(out),'wb') as f:f.setnchannels(2);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(pcm.tobytes())
print('Saved',out,out.stat().st_size,flush=True)
