import fs from 'node:fs';import path from 'node:path';import {build} from 'esbuild';import opentype from 'opentype.js';
const root=path.resolve(import.meta.dirname,'..');process.chdir(root);
const font=opentype.loadSync(fs.existsSync('vendor/Nunito-Black.ttf')?'vendor/Nunito-Black.ttf':'vendor/Nunito.ttf');const glyphs={};
for(let code=32;code<127;code++){const ch=String.fromCharCode(code),g=font.charToGlyph(ch),p=g.getPath(0,0,1000);const o=[];for(const c of p.commands){if(c.type==='M'||c.type==='L')o.push(c.type.toLowerCase(),c.x,-c.y);else if(c.type==='Q')o.push('q',c.x,-c.y,c.x1,-c.y1);else if(c.type==='C')o.push('b',c.x,-c.y,c.x1,-c.y1,c.x2,-c.y2);}glyphs[ch]={ha:g.advanceWidth*1000/font.unitsPerEm,x_min:0,x_max:1000,o:o.join(' ')};}
fs.writeFileSync('vendor/nunito.typeface.json',JSON.stringify({glyphs,familyName:'Nunito',ascender:1000,descender:-250,underlinePosition:-100,underlineThickness:50,boundingBox:{xMin:-300,xMax:1500,yMin:-300,yMax:1200},resolution:1000,original_font_information:{license:'SIL Open Font License; see NUNITO-OFL.txt'}}));
const result=await build({absWorkingDir:root,entryPoints:['src/film.js'],bundle:true,write:false,format:'iife',minify:true,legalComments:'inline',plugins:[{name:'vendor',setup(b){b.onResolve({filter:/^three$/},()=>({path:path.join(root,'vendor/build/three.module.js')}));}}]});
let js=result.outputFiles[0].text;
const assets={};for(const name of fs.readdirSync('assets')){if(/\.(mp4|png|webp)$/.test(name)){const mime=name.endsWith('.mp4')?'video/mp4':name.endsWith('.png')?'image/png':'image/webp';assets[name]='data:'+mime+';base64,'+fs.readFileSync('assets/'+name).toString('base64');}}
// Replace source placeholders before bundling through a second build.
const source=fs.readFileSync('src/film.js','utf8').replace('/*ASSETS*/{}',JSON.stringify(assets)).replace('/*TYPEFACE*/{}',fs.readFileSync('vendor/nunito.typeface.json','utf8'));
fs.writeFileSync('src/.film.generated.js',source);
const packed=await build({absWorkingDir:root,entryPoints:['src/.film.generated.js'],bundle:true,write:false,format:'iife',minify:true,legalComments:'inline',plugins:[{name:'vendor',setup(b){b.onResolve({filter:/^three$/},()=>({path:path.join(root,'vendor/build/three.module.js')}));}}]});
fs.unlinkSync('src/.film.generated.js');
let html=fs.readFileSync('src/player.html','utf8').replace('/*BUNDLE*/',packed.outputFiles[0].text);
html=html.replace('/*FONT*/',fs.readFileSync('vendor/Nunito.ttf').toString('base64'));
fs.writeFileSync('animation.html',html);console.log('Built offline player:',Buffer.byteLength(html),'bytes');
