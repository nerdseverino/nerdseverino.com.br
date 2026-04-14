---
title: "Quiz Linux"
layout: "single"
url: "/quiz/"
---

<style>
.quiz-container{max-width:800px;margin:0 auto;font-family:inherit}
.quiz-header{text-align:center;margin-bottom:2rem}
.quiz-config{text-align:center;margin:2rem 0}
.quiz-config select,.quiz-config button{padding:8px 16px;margin:4px;border-radius:6px;border:1px solid var(--border);background:var(--entry);color:var(--primary);font-size:1rem;cursor:pointer}
.quiz-config button{background:var(--tertiary);font-weight:bold}
.question-card{background:var(--entry);border-radius:8px;padding:1.5rem;margin-bottom:1.5rem;border:1px solid var(--border)}
.question-num{font-size:.85rem;color:var(--secondary);margin-bottom:.5rem}
.question-text{font-size:1.1rem;margin-bottom:1rem;line-height:1.5}
.option{display:block;padding:10px 14px;margin:6px 0;border-radius:6px;border:1px solid var(--border);cursor:pointer;transition:all .2s}
.option:hover{border-color:var(--primary)}
.option.selected{border-color:#3b82f6;background:rgba(59,130,246,.1)}
.option.correct{border-color:#22c55e;background:rgba(34,197,94,.15)}
.option.wrong{border-color:#ef4444;background:rgba(239,68,68,.15)}
.option.disabled{pointer-events:none}
.progress{text-align:center;margin:1rem 0;color:var(--secondary)}
.results{text-align:center;padding:2rem}
.score{font-size:3rem;font-weight:bold;margin:1rem 0}
.score.good{color:#22c55e}.score.ok{color:#eab308}.score.bad{color:#ef4444}
.topic-review{text-align:left;margin:1.5rem auto;max-width:500px}
.topic-review li{margin:4px 0;color:var(--secondary)}
.btn{padding:10px 24px;border-radius:6px;border:none;cursor:pointer;font-size:1rem;font-weight:bold;background:var(--tertiary);color:var(--primary);margin:4px}
.btn:hover{opacity:.8}
.hidden{display:none}
</style>

<div class="quiz-container">
<div id="setup" class="quiz-config">
<p>Escolha quantas perguntas:</p>
<select id="qcount">
<option value="10">10 perguntas</option>
<option value="20" selected>20 perguntas</option>
<option value="30">30 perguntas</option>
<option value="50">50 perguntas</option>
<option value="0">Todas</option>
</select>
<br><br>
<button class="btn" onclick="startQuiz()">Iniciar Quiz</button>
</div>

<div id="quiz" class="hidden">
<div class="progress" id="progress"></div>
<div id="questions"></div>
<div style="text-align:center;margin:2rem 0">
<button class="btn" id="btnFinish" onclick="finish()" style="display:none">Ver Resultado</button>
</div>
</div>

<div id="results" class="hidden results">
<h2>Resultado</h2>
<div class="score" id="scoreText"></div>
<p id="scoreDetail"></p>
<div class="topic-review" id="topicReview"></div>
<button class="btn" onclick="location.reload()">Tentar Novamente</button>
</div>
</div>

<script>
let questions=[],selected={},total=0;

function shuffle(a){for(let i=a.length-1;i>0;i--){let j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]]}return a}

async function startQuiz(){
const res=await fetch('/quiz/questions.json');
let all=await res.json();
let count=parseInt(document.getElementById('qcount').value);
if(count===0)count=all.length;
shuffle(all);
questions=all.slice(0,count);
total=questions.length;
// Randomize options for each question
questions.forEach(q=>{
let opts=q.options.map((t,i)=>({text:t,orig:i}));
shuffle(opts);
q.shuffledOpts=opts;
q.correctShuffled=opts.findIndex(o=>o.orig===q.correct);
});
document.getElementById('setup').classList.add('hidden');
document.getElementById('quiz').classList.remove('hidden');
render();
}

function render(){
let html='';
questions.forEach((q,i)=>{
let sel=selected[i];
let answered=sel!==undefined;
html+=`<div class="question-card">
<div class="question-num">Pergunta ${i+1}/${total} — ${q.topic}</div>
<div class="question-text">${q.question}</div>`;
q.shuffledOpts.forEach((o,j)=>{
let cls='option';
if(answered){
cls+=' disabled';
if(j===q.correctShuffled)cls+=' correct';
else if(j===sel)cls+=' wrong';
}else if(sel===j)cls+=' selected';
html+=`<div class="${cls}" onclick="pick(${i},${j})">${String.fromCharCode(65+j)}) ${o.text}</div>`;
});
html+=`</div>`;
});
document.getElementById('questions').innerHTML=html;
let answered=Object.keys(selected).length;
document.getElementById('progress').textContent=`${answered}/${total} respondidas`;
document.getElementById('btnFinish').style.display=answered===total?'inline-block':'none';
}

function pick(qi,oi){
if(selected[qi]!==undefined)return;
selected[qi]=oi;
render();
}

function finish(){
let correct=0,wrongTopics=[];
questions.forEach((q,i)=>{
if(selected[i]===q.correctShuffled)correct++;
else wrongTopics.push(q.topic);
});
let pct=Math.round(correct/total*100);
let cls=pct>=70?'good':pct>=50?'ok':'bad';
document.getElementById('quiz').classList.add('hidden');
document.getElementById('results').classList.remove('hidden');
document.getElementById('scoreText').className='score '+cls;
document.getElementById('scoreText').textContent=pct+'%';
document.getElementById('scoreDetail').textContent=`${correct} de ${total} corretas`;
let unique=[...new Set(wrongTopics)];
if(unique.length>0){
let html='<h3>Tópicos para revisar:</h3><ul>';
unique.forEach(t=>html+=`<li>${t}</li>`);
html+='</ul>';
document.getElementById('topicReview').innerHTML=html;
}else{
document.getElementById('topicReview').innerHTML='<p>Parabéns! Acertou tudo! 🎉</p>';
}
}
</script>
