import fs from 'node:fs/promises';
const dir=new URL('.',import.meta.url);
const rows=JSON.parse(await fs.readFile(new URL('story_dialogue.json',dir),'utf8'));
const changes={
 'OPN-03': ['한 판 어때요? 이기면 오늘 술값을 깎아 드릴게요.','[구현 프로토타입] 첫 실행 도입에서 순서대로 표시.'],
 '13-HINT':['공 이동은 200점을 내고 바로 쓸 수 있어요. 직접 득점은 없지만, 길을 만들 수 있죠.','[기획 / 게임 미연결] 선택형 도움말. 후속 스토리 대전의 구매형 아이템 규칙.'],
 '31-HINT':['공 이동에 200점을 쓰면 공의 자리를 바꿀 수 있어요. 이 행동 자체로 점수는 얻지 못해요.','[기획 / 게임 미연결] 선택형 도움말. 후속 스토리 대전의 구매형 아이템 규칙.'],
 '33-HINT':['400점을 내면 이번 턴 동안 파울 공을 모두 치울 수 있어요. 턴이 끝나면 원래 자리로 돌아옵니다.','[기획 / 게임 미연결] 선택형 도움말. 후속 스토리 대전의 구매형 아이템 규칙.'],
 '34-HINT':['위험 샷은 800점이에요. 1쿠션 성공은 1,000점, 2쿠션 성공은 10,000점. 파울이면 누적 점수가 0이 돼요.','[기획 / 게임 미연결] 선택형 도움말. 후속 스토리 대전의 구매형 아이템 규칙.'],
 '43-HINT':['위험 샷은 800점을 내고 씁니다. 파울이면 누적 점수가 0이 되니 붉은 공 위치를 확인해요.','[기획 / 게임 미연결] 선택형 도움말. 후속 스토리 대전의 구매형 아이템 규칙.'],
 'SYS-04':['위험 샷에서 파울이에요. 누적 점수가 0으로 돌아갑니다.','[기획 / 게임 미연결] 후속 스토리 대전 위험 샷 파울 확정 후. 게이지 초기화 문구 제거.'],
 'SYS-06':['공 이동은 200점을 내고 바로 씁니다. 공의 자리를 바꿀 뿐 직접 득점은 없어요.','[기획 / 게임 미연결] 후속 스토리 대전 공 이동 구매 안내. 무료 지급/게이지 전제 없음.'],
 'SYS-07':['파울 제거는 400점을 내고 바로 씁니다. 이번 턴 동안 파울 공을 모두 치워요.','[기획 / 게임 미연결] 후속 스토리 대전 파울 제거 구매 안내. 무료 지급/게이지 전제 없음.'],
 'SYS-08':['위험 샷은 800점을 내고 바로 씁니다. 1쿠션은 1,000점, 2쿠션은 10,000점. 파울이면 누적 점수가 0이 돼요.','[기획 / 게임 미연결] 후속 스토리 대전 위험 샷 구매 안내. 무료 지급/게이지 전제 없음.']
};
for(const row of rows)if(changes[row.id]){[row.line,row.direction]=changes[row.id];}
const planned='[기획 / 게임 미연결] 후속 스토리 대전 전용. 현재 300점 첫 판 프로토타입에는 연결되지 않음.';
const add=(id,trigger,line,note)=>{if(rows.some(r=>r.id===id))return;rows.push({id,chapter:'공통',stage:'후속 스토리 대전',trigger,speaker:'바텐더',line,direction:`${planned} ${note}`});};
add('HCP-PRE-01','later_match_setup','제가 이 테이블에 익숙하니, 손님은 아이템을 써도 좋아요. 대신 쓸 때마다 점수로 값을 치릅니다.','시작 전 핸디캡 설명. 선택 옵션 아님.');
add('HCP-PRICE-01','later_match_setup_next','공 이동 200점, 파울 제거 400점, 위험 샷 800점. 가진 점수로 사면 바로 사용되고 비용만큼 총점이 줄어요.','가격은 현재 보유 총점에서 구매 성공 시 차감.');
add('ITEM-MOVE-USE-01','item_move_purchase_success','200점을 내고 공을 옮겼군요. 이동 자체로 점수는 없지만, 이제 길이 달라졌어요.','구매 성공: 총점 -200, 공 이동 효과 적용 후.');
add('ITEM-MOVE-NOFUNDS-01','item_move_insufficient_score','공 이동은 200점이에요. 지금 점수로는 살 수 없네요.','현재 총점<200. 점수 차감·효과 적용 없음.');
add('ITEM-REMOVE-USE-01','item_remove_purchase_success','400점을 내고 이번 턴 동안 파울 공을 모두 치웠네요. 턴이 끝나면 돌아옵니다.','구매 성공: 총점 -400, 현재 파울 공을 모두 임시 제거하고 턴 종료 때 원래 좌표에 복원.');
add('ITEM-REMOVE-NOFUNDS-01','item_remove_insufficient_score','파울 제거는 400점이에요. 지금 점수로는 살 수 없네요.','현재 총점<400. 점수 차감·효과 적용 없음.');
add('ITEM-RISK-USE-01','item_risk_purchase_success','800점을 내고 위험 샷을 골랐군요. 1쿠션 성공은 1,000점, 2쿠션 성공은 10,000점이에요.','구매 성공: 총점 -800, 위험 샷 적용 후. 파울이면 누적 점수 0.');
add('ITEM-RISK-NOFUNDS-01','item_risk_insufficient_score','위험 샷은 800점이에요. 지금 점수로는 살 수 없네요.','현재 총점<800. 점수 차감·효과 적용 없음.');
add('ITEM-RISK-ONE-01','item_risk_one_cushion_score','한 번의 쿠션으로 1,000점! 800점을 걸 만한 한 수였네요.','위험 샷 유효 득점: 1쿠션=1000. 구매비용 -800은 사용 시 이미 차감됨.');
add('ITEM-RISK-TWO-01','item_risk_two_cushion_score','두 번의 쿠션으로 10,000점이라니! 이건 저도 예상 못 했어요.','위험 샷 유효 득점: 2쿠션=10000. 구매비용 -800은 사용 시 이미 차감됨.');
add('ITEM-RISK-FOUL-01','item_risk_foul','파울이에요. 위험 샷의 대가로 누적 점수가 0이 됐습니다.','위험 샷 파울 확정 후. 구매비용 -800 차감 여부와 관계없이 누적 점수 0.');
const csv=s=>'"'+String(s).replaceAll('"','""')+'"';
const header=['ID','챕터','스테이지','트리거','화자','대사','연출·구현 메모'];
await fs.writeFile(new URL('story_dialogue.json',dir),JSON.stringify(rows,null,2),'utf8');
await fs.writeFile(new URL('story_dialogue.csv',dir),[header.join(','),...rows.map(r=>[r.id,r.chapter,r.stage,r.trigger,r.speaker,r.line,r.direction].map(csv).join(','))].join('\r\n'),'utf8');
console.log(JSON.stringify({count:rows.length,changed:rows.map((r,i)=>({...r,index:i})).filter(r=>changes[r.id]),added:rows.slice(-11)}));
