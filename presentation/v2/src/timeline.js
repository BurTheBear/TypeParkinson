export const scenes = [
 {id:'contact',name:'A simple word',p:8,s:10,title:'A simple word.',sub:'',note:'Illustrative touch sequence'},
 {id:'need',name:'Hands change',p:8,s:15,title:'Hands change.',sub:'1.1 million Americans.',note:'Estimate: Parkinson’s Foundation · parkinson.org/statistics'},
 {id:'reveal',name:'TypeParkinson',p:10,s:12,title:'TypeParkinson',sub:'A keyboard that learns your hands.',note:''},
 {id:'touch',name:'Your touch model',p:12,s:18,title:'Your touch.\nYour keyboard.',sub:'',note:'Illustrative touch model'},
 {id:'correction',name:'Smart correction',p:14,s:22,title:'Intent, understood.',sub:'Undo stays yours.',note:'Examples from the decoder’s automated tests'},
 {id:'motion',name:'Motion into meaning',p:12,s:19,title:'Motion → meaning.',sub:'Measure. Never diagnose.',note:'Illustrative spectrum · simulator sensor samples'},
 {id:'compare',name:'Check the difference',p:10,s:16,title:'Check the difference.',sub:'DEMO DATA',note:'Sample comparison, not clinical evidence'},
 {id:'engineering',name:'Built on your iPhone',p:11,s:20,title:'On-device by design.',sub:'',note:'67 automated tests passed · simulator, October 24, 2026'},
 {id:'daily',name:'Built around your day',p:13,s:17,title:'More ways\nto connect.',sub:'',note:'Sample activity history and insights'},
 {id:'privacy',name:'Your words',p:7,s:9,title:'On your iPhone.',sub:'Your words stay yours.',note:'Keyboard saves numbers, never typed text. Speak saves phrases locally.'},
 {id:'end',name:'TypeParkinson',p:7,s:10,title:'TypeParkinson',sub:'A keyboard that learns your hands.',note:''}
];
export const narration = [
 ['A simple word. Hello. But when a hand trembles, one intended tap can become several. We want the keyboard to adapt to the person.'],
 ['An estimated 1.1 million Americans live with Parkinson’s, according to the Parkinson’s Foundation. Tremor and stiffness can make fine motor tasks harder. Some people also experience a quieter voice.'],
 ['We are Atharv Sharma and Pranav Atreya, freshmen at Livingston High School in New Jersey. This is TypeParkinson: an iPhone app and system keyboard built with Swift and SwiftUI.'],
 ['First, short setup exercises measure where touches land. A two-dimensional Gaussian describes the person’s offset and spread. The keyboard uses that personal touch model, and a standard-versus-personal check lets the user compare their own typing.'],
 ['Next, smart correction combines touch evidence with word likelihood. A dynamic-programming alignment considers repeated touches, missing letters and swapped letters. Tje can become the; hellloo becomes hello. A one-tap Undo keeps the person in control. These are tested examples, not patient outcomes.'],
 ['An expert-set naive Bayes model describes touch patterns; it does not diagnose Parkinson’s. Core Motion recordings use a windowed Fourier analysis to estimate shaking strength and frequency. AVFoundation supports relative voice-volume practice and speaking typed messages. This five-hertz graphic and the sensor readings are illustrative samples.'],
 ['The app includes a direct comparison screen. Here, demo data shows four errors versus one and six fixes versus two. These sample numbers explain the check. They are not a clinical study or a promise of improvement.'],
 ['The engineering stays on the device. The app shares numerical settings through an App Group with the custom keyboard extension. Here is the real Swift candidate-scoring code. The current simulator run passed 67 automated tests across 13 suites. Hardware and keyboard integration still need real-device validation.'],
 ['The same app brings together a daily check, spiral and rhythm practice, a tremor meter, voice practice and Speak. Progress, medication logs and PDF or CSV exports help a person bring observations to their care team. Displayed histories are sample data.'],
 ['There is no TypeParkinson server. The keyboard stores numerical touch parameters, never typed text. Speak can save phrases and recent messages locally. These measurements describe activity; they do not diagnose disease.'],
 ['TypeParkinson. A keyboard that learns your hands. Atharv Sharma and Pranav Atreya, Livingston High School, New Jersey. Congressional App Challenge 2026. AI assistance and open-source dependencies are documented with the project.']
];
export function timeline(cut='presenter') {let t=0;return scenes.map((s,i)=>{const d=s[cut==='submission'?'s':'p'];const r={...s,i,start:t,end:t+d,duration:d};t+=d;return r;});}
export function at(t,cut='presenter'){const a=timeline(cut);return a.find(s=>t<s.end)||a.at(-1);}
export function captionCues(){const cues=[];for(const s of timeline('submission')){const words=narration[s.i][0].split(' ');const count=Math.ceil(words.length/13);for(let i=0;i<count;i++){const chunk=words.slice(i*13,(i+1)*13).join(' ');cues.push({start:s.start+i*s.duration/count,end:s.start+(i+1)*s.duration/count,text:chunk});}}return cues;}
