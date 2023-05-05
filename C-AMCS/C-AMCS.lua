--------------------------------------------
-- Title    : C-AMCS Display Control.Lua
-- Autor    : TorpolM
-- Ver      : 1.0.0 @2023.04.22
--              ・New Relese
--------------------------------------------


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



-------------------------------
-- グローバル変数             --
-------------------------------
----- 内部状態管理 -----
FlgSpdCtrlMode = 0		--速度制御モード ・・・ 0:手動 1:自動 2:ｳｪｲﾎﾟｲﾝﾄ
FlgCrsCtrlMode = 0		--針路制御モード ・・・ 0:手動 1:自動 2:ｳｪｲﾎﾟｲﾝﾄ
FlgAziDispMode = false	--針路制御グラフィカル表示 ・・・ true:舵角モード false:コンパスモード

CrtCourse = 0           --現在針路[rad]
TgtCourse = 0           --目標針路[rad]
TgtCourse_old = 0       --目標針路(前回値)


----- ボタン生成 -----
btnCrsRud       = add_btn(49,0,64,6)    --針路制御グラフィカル表示切替ボタン
btnCrsGraphic   = add_btn(20,9,60,49)   --針路制御グラフィカル表示ボタン
btnCrsCtrlMode  = add_btn(41,53,64,64)  --針路制御モード切替ボタン
btnSpdCtrlMode  = add_btn(0,53,22,64)   --速度制御モード切替ボタン


function onTick()
	----- 外部入力取得 -----
	CrtCourse = input.getNumber(5) * math.pi * 2
	touchData = {input.getNumber(3), input.getNumber(4), input.getBool(1)}

	
	----- ボタン状態更新 -----
	btnCrsRud:tick(touchData)
	btnCrsGraphic:tick(touchData)
	btnCrsCtrlMode:tick(touchData)
	btnSpdCtrlMode:tick(touchData)
	
	
	----- ボタンイベント処理 -----
	-- CRS/RUDボタンが押下されていたら針路制御グラフィカル表示をトグルする
	if btnCrsRud.pushed then FlgAziDispMode = not FlgAziDispMode end
	
    --針路制御グラフィカル表示:コンパス
	if not FlgAziDispMode then
        --目標針路を設定(短押し)orリセット(長押し)
		if  btnCrsGraphic.pushed and btnCrsGraphic.pushTime < 60 then
			TgtCourse = math.atan(btnCrsGraphic.pushedX - 40, -btnCrsGraphic.pushedY + 29)
		elseif btnCrsGraphic.pushTime == 60 then
			TgtCourse = CrtCourse
		end
    --針路制御グラフィカル表示:舵角
	else
		
	end
	
	--針路制御モード切替
	if btnCrsCtrlMode.pushed and btnCrsCtrlMode.pushTime < 60 then 
		if FlgCrsCtrlMode == 0 then
			FlgCrsCtrlMode = 1
		else
			FlgCrsCtrlMode = 0
		end
	elseif btnCrsCtrlMode.pushTime == 60 then
		if FlgCrsCtrlMode == 2 then
			FlgCrsCtrlMode = 1
		else
			FlgCrsCtrlMode = 2
		end
	end
	
	--速度制御モード切替
	if btnSpdCtrlMode.pushed and btnSpdCtrlMode.pushTime < 60 then 
		if FlgSpdCtrlMode == 0 then
			FlgSpdCtrlMode = 1
		else
			FlgSpdCtrlMode = 0
		end
	elseif btnSpdCtrlMode.pushTime == 60 then
		if FlgSpdCtrlMode == 2 then
			FlgSpdCtrlMode = 1
		else
			FlgSpdCtrlMode = 2
		end
	end
	
end

function onDraw()
	--画面クリア
    screen.setColor(8,8,8)
    screen.drawClear()

    ----- グラフィカル表示部 -----
	if not FlgAziDispMode then
        --コンパスの背景
    	screen.setColor(8,12,24)
    	screen.drawCircleF(40,29,20)
    	screen.setColor(196,196,196,18)
    	screen.drawLine(40,12,40,46)
    	screen.drawLine(23,29,58,29)
    	screen.setColor(64,0,0)
    	screen.drawText(38,11,"N")
		screen.setColor(196,196,196)
		screen.drawText(22,26,"E")
		screen.drawText(54,26,"W")
		screen.drawText(38,43,"S")
    	screen.setColor(4,6,12)
    	screen.drawCircle(40,29,20)

		 --目標針路表示
    	screen.setColor(255,0,0)
    	screen.drawTriangleF(
    		40 + math.sin(TgtCourse) * 14,29 - math.cos(TgtCourse) * 14,
    		40 + math.sin(TgtCourse+math.pi*0.5) * 2,29 - math.cos(TgtCourse+math.pi*0.5) * 2,
    		40 + math.sin(TgtCourse-math.pi*0.5) * 2,29 - math.cos(TgtCourse-math.pi*0.5) * 2
    	)
    
    	--現在針路表示
    	screen.setColor(46,75,40)
    	screen.drawTriangleF(
    		40 + math.sin(CrtCourse) * 10,29 - math.cos(CrtCourse) * 10,
    		40 + math.sin(CrtCourse+math.pi*0.66) * 5,29 - math.cos(CrtCourse+math.pi*0.66) * 5,
    		40 + math.sin(CrtCourse-math.pi*0.66) * 5,29 - math.cos(CrtCourse-math.pi*0.66) * 5
    	)

		--CRS/RUDボタン
    	screen.setColor(255,255,255)
    	screen.drawText(49,0,"CRS")
	else
		screen.setColor(4,6,12)
		screen.drawCircleF(40,10,33)
		screen.setColor(8,12,24)
		screen.drawCircleF(40,10,32)
		screen.setColor(46,75,40)
		screen.drawCircleF(40,11,7)
		screen.setColor(8,8,8)
		screen.drawRectF(0,0,64,10)
		screen.drawRectF(0,0,24,64)
		screen.drawRectF(56,10,10,64)
		screen.drawTriangleF(24,10,24,42,40,10)
		screen.drawTriangleF(56,10,56,42,40,10)
		screen.setColor(4,6,12)
		screen.drawLine(40,10,24,42)
		screen.drawLine(40,10,56,42)
		
		screen.setColor(196,196,196)
		screen.drawText(38,44,"M")
		screen.drawText(54,40,"S")
		screen.drawText(20,40,"P")
		
		--CRS/RUDボタン
    	screen.setColor(255,255,255)
    	screen.drawText(49,0,"RUD")
	end
	
	--現在針路表示欄
	screen.setColor(16,16,16)
	screen.drawRectF(31,0,16,8)
	screen.setColor(196,196,196)
    screen.drawText(33,2,string.format("%03f", math.floor(2*math.pi*CrtCourse/180)))
    screen.drawRect(31,0,16,8)
    
   
	
	--mode:auto button
	screen.setColor(255,255,255)
	if FlgCrsCtrlMode == 0 then
	    screen.drawText(45,55,"MAN")
	elseif FlgCrsCtrlMode == 1 then
		screen.drawText(43,55,"AUTO")
	elseif FlgCrsCtrlMode == 2 then
		screen.drawText(45,55,"WPT")
	end
    screen.drawRect(41,53,22,8)
    
    


    ------------------------
    -- speed
    ------------------------
	--course readout
	screen.setColor(16,16,16)
	screen.drawRectF(3,0,16,8)
	screen.setColor(196,196,196)
    screen.drawText(5,2,"028")
    screen.drawRect(3,0,16,8)

	--grapyic
	screen.setColor(8,12,24)
    screen.drawRectF(6,10,5,25)
	screen.drawRectF(6,35,5,15)
    screen.setColor(4,6,12)
    screen.drawRect(6,10,5,25)
	screen.drawRect(6,35,5,15)
	
	--target speed handle
	screen.setColor(32,32,32)
	screen.drawTriangleF(18,9,7,12,18,15)
	
	--shortcuts buttons
	screen.setColor(196,196,196)
	screen.drawText(1,10,"F")
    screen.drawText(1,32,"S")
    screen.setColor(64,0,0)
    screen.drawText(1,46,"R")

    --mode:auto button
	screen.setColor(255,255,255)
	if FlgSpdCtrlMode == 0 then
		screen.drawText(4,55,"MAN")
	elseif FlgSpdCtrlMode == 1 then
		screen.drawText(2,55,"AUTO")
	elseif FlgSpdCtrlMode == 2 then
		screen.drawText(4,55,"WPT")
	end
    
    screen.drawRect(0,53,22,8)
end