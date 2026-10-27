import fs from 'node:fs/promises';
const dir = new URL('.', import.meta.url);
const rows = JSON.parse(await fs.readFile(new URL('story_dialogue.json',dir),'utf8'));
const starts = {
 '11-START':'첫 판이에요. 저보다 먼저 300점을 내면 술값을 깎아 드리죠. 목표 공을 맞혀 보세요.',
 '12-START':'이젠 벽을 한 번 거친 점수만 인정해요. 제 차례가 오기 전에 길을 찾아봐요.',
 '13-START':'붉은 공에 닿으면 이번 점수는 취소, 200점도 잃어요. 제 점수를 따라잡으려다 무리하진 마요.',
 '14-START':'벽 한 번에 파울 세금까지. 이번 판도 제 점수보다 앞설 수 있을까요?',
 '21-START':'이제 봐주는 횟수를 줄일게요. 득점해도 기회는 한 번만 돌아와요. 제가 앞서기 전에 결정해요.',
 '22-START':'벽을 두 번 거쳐야 점수예요. 저도 같은 조건으로 칠 테니 핑계는 없겠죠?',
 '23-START':'파울은 200점 손해, 회복은 한 번. 제 점수를 쫓을지 기회를 지킬지 선택해요.',
 '24-START':'두 번의 벽에 기회도 빠듯해요. 이제 제 손도 덜 늦출 겁니다. 점수판을 뒤집어 봐요.',
 '31-START':'공이 길을 막으면 옮길 수도 있어요. 제가 치기 전에 유리한 배치를 만들어 보죠.',
 '32-START':'이번엔 위험 샷 점수만 목표에 들어갑니다. 저보다 큰 한 방을 칠 수 있겠어요?',
 '33-START':'붉은 공을 지워도 좋아요. 하지만 쿠션 두 번은 필요하죠. 제 차례까지 아껴 둘 건가요?',
 '34-START':'위험 샷으로만 목표를 채우고 기회도 아껴야 해요. 이번엔 저도 진짜로 겨룹니다.',
 '41-START':'두 번의 벽, 적은 회복. 설명은 여기까지. 이제 점수판으로 대답해 주세요.',
 '42-START':'지금까지 번 점수도 걸려 있어요. 붉은 공 하나에 200점. 제 추격을 버텨 보세요.',
 '43-START':'큰 점수만 목표에 들어가요. 위험 샷에서 파울이면 전부 잃죠. 저보다 앞설 자신 있나요?',
 '44-START':'마지막 판. 두 번의 벽, 적은 기회, 파울 세금. 저도 전력으로 칩니다. 누가 술값을 낼지 정하죠.'
};
for (const row of rows) if (starts[row.id]) { row.line=starts[row.id]; if(!row.direction.includes('대결 기준: 손님 점수와 바텐더 점수를 함께 표시.'))row.direction+=' 대결 기준: 손님 점수와 바텐더 점수를 함께 표시.'; }
const add=(id,trigger,line,condition,variant)=>{if(rows.some(r=>r.id===id))return;rows.push({id,chapter:'공통',stage:'대결 반응',trigger,speaker:'바텐더',line,direction:`[구현 프로토타입 / 런타임 검증 대기] ${condition} / 변형 ${variant}. 샷 판정 확정 후.${trigger==='close_score'?'':' 고득점으로 즉시 종료되면 결과 화면에도 반응 유지.'}`});};
add('EVT-PLAYER-MISS-01','player_shot_zero','빈손이네요? 제 차례엔 공이 좀 움직일 겁니다.','손님 샷 득점=0, 파울=false','A');
add('EVT-PLAYER-MISS-02','player_shot_zero','그 공은 아쉽네요. 자, 이번엔 제가 보여 드리죠.','손님 샷 득점=0, 파울=false','B');
add('EVT-PLAYER-HIGH-01','player_shot_high','잠깐, 그 각도를 읽었다고요? 생각보다 훨씬 잘 치시네요.','손님 단일 샷 확정 유효 득점>1000, 파울=false','A');
add('EVT-PLAYER-HIGH-02','player_shot_high','그 점수는 예상 밖인데요. 제가 슬슬 진지해져야겠어요.','손님 단일 샷 확정 유효 득점>1000, 파울=false','B');
add('EVT-BARTENDER-HIGH-01','bartender_shot_high','봤죠? 이 테이블에선 제가 조금 더 익숙합니다.','바텐더 단일 샷 확정 유효 득점>1000, 파울=false','A');
add('EVT-BARTENDER-HIGH-02','bartender_shot_high','벽을 몇 번이나 거쳤죠. 술값 계산이 다시 재밌어지네요.','바텐더 단일 샷 확정 유효 득점>1000, 파울=false','B');
add('EVT-PLAYER-FOUL-01','player_foul','붉은 공에 닿았네요. 승부가 저한테 기울겠는데요?','손님 샷 파울=true; 0점 놀림보다 우선','A');
add('EVT-PLAYER-FOUL-02','player_foul','아쉬운 실수예요. 제가 그 틈을 놓칠 것 같나요?','손님 샷 파울=true; 0점 놀림보다 우선','B');
add('EVT-BARTENDER-FOUL-01','bartender_foul','제 실수예요. 이번엔 당신이 웃을 차례군요.','바텐더 샷 파울=true; 0점 반응보다 우선','A');
add('EVT-BARTENDER-FOUL-02','bartender_foul','이런, 붉은 공이라니. 방심한 값을 치렀네요.','바텐더 샷 파울=true; 0점 반응보다 우선','B');
add('EVT-CLOSE-01','close_score','점수 차가 200점 이내네요. 이제 한 번의 쿠션이 승부를 바꿔요.','양측 총점>0, abs(손님 총점-바텐더 총점)<=200, 어느 쪽도 300점 도달 전','A');
add('EVT-CLOSE-02','close_score','바로 뒤에 있군요. 좋아요, 이래야 승부답죠.','양측 총점>0, abs(손님 총점-바텐더 총점)<=200, 어느 쪽도 300점 도달 전','B');
add('EVT-PLAYER-SCORE-01','player_shot_score','좋은 샷이에요. 각도를 잘 읽으셨네요.','손님 단일 샷 확정 유효 득점 100~1000 포함, 파울=false','A');
add('EVT-BARTENDER-SCORE-01','bartender_shot_score','깔끔하게 들어갔죠? 제 점수도 올라갑니다.','바텐더 단일 샷 확정 유효 득점 100~1000 포함, 파울=false','A');
add('EVT-BARTENDER-MISS-01','bartender_shot_zero','이런, 제 공도 말을 안 듣네요. 이번엔 당신 차례예요.','바텐더 샷 득점=0, 파울=false','A');
const csv=v=>'"'+String(v).replaceAll('"','""')+'"';
await fs.writeFile(new URL('story_dialogue.json',dir),JSON.stringify(rows,null,2),'utf8');
const h=['ID','챕터','스테이지','트리거','화자','대사','연출·구현 메모'];
await fs.writeFile(new URL('story_dialogue.csv',dir),[h.join(','),...rows.map(r=>[r.id,r.chapter,r.stage,r.trigger,r.speaker,r.line,r.direction].map(csv).join(','))].join('\r\n'),'utf8');
console.log(JSON.stringify({count:rows.length,updates:rows.map((r,i)=>({...r,index:i})).filter(r=>starts[r.id]),added:rows.slice(-15)}));
