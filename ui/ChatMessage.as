class ChatMessage{
	public var PlayerName:String;
	public var Message:String;
	public var Type:String;
	public var NameFont:TextFormat

	public var TimeStamp:Number;
	public var NameWidth:Number;
	public var NumOfLines:Number;
	
	public static var AlienFont:TextFormat
	public static var MarineFont:TextFormat
	public static var SpectatorFont:TextFormat
	
	public function IsEmpty(){
	}
	
	public function ChatMessage(MsgInfo:Array, Index:Number){
		this.ParseMessage(MsgInfo, Index)
	}
	
	public function ParseMessage(msginfo:Array, Index:Number){		
		this.Type = msginfo[Index+0]
		this.Message = msginfo[Index+2];
		
		this.TimeStamp = getTimer()
		this.NumOfLines = 0

		if(msginfo[Index+1] <> ""){
			this.PlayerName = msginfo[Index+1]+':';
			if(msginfo[Index+0] == "Alien"){
				this.NameFont = AlienFont
			}else if(msginfo[Index+0] == "Marine"){
				this.NameFont = MarineFont
			}else{
				this.NameFont = SpectatorFont
			}
		}else{
			this.PlayerName = ""
		}
	}
}