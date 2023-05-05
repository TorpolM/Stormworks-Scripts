-------------------------------
-- ボタン処理
-------------------------------
function add_btn(_x1,_y1,_x2,_y2)
	return 
    {
		pushed = false,             --押下ﾌﾗｸﾞ
		touchedX=- 1,               --タッチされた位置X
		touchedY=- 1,               --タッチされた位置Y
		pushedX=- 1,                --押下位置X
		pushedY=- 1,                --押下位置Y
		pushTime=0,                 --押下時間(tick)
		touched_old=false,	        --【内部用】前回押下ﾌﾗｸﾞ
		x1=_x1,				        --【内部用】ボタン左上座標X
		y1=_y1,				        --【内部用】ボタン左上座標Y
		x2=_x2,				        --【内部用】ボタン右下座標X
		y2=_y2,				        --【内部用】ボタン右下座標Y

		tick=function(self,touch)   --ボタン状態更新処理(param:タッチ情報[X,Y])
			--プッシュ位置の更新
			self.pushedX, self.pushedY = self.touchedX, self.touchedY
			
			--タッチ座標が範囲内であればカウントアップ(長押し検知用)
			if	self.touched_old 
				and self.x1 		< self.touchedX 
				and self.touchedX	< self.x2 
				and self.y1 		< self.touchedY 
				and self.touchedY	< self.y2 
			then
				self.pushTime = self.pushTime + 1
			end
		
            --押上判定
			if	self.touched_old 
				and not touch[3] 
				and self.x1 		< self.touchedX 
				and self.touchedX	< self.x2 
				and self.y1 		< self.touchedY 
				and self.touchedY	< self.y2 
			then
				self.pushed = true
			else
				self.pushed = false
			end
		
            --押されていなければカウンタをリセット
			if not self.touched_old then
				self.pushTime = 0
			end
		
            --前回状態を後進する
			self.touchedX, self.touchedY, self.touched_old = touch[1], touch[2], touch[3]
		end
	}
end