class ChatRingBuffer{
		
		public var MaxSize:Number;
		public var Count:Number;
		public var Start:Number;
		public var End:Number; //really this is hole/next index to write to
		public var RingBuffer:Array;
		
		public function ChatRingBuffer(maxsize){
			this.MaxSize = maxsize
			this.Count = 0
			this.Start = 0
			this.End = 0
			this.RingBuffer = Array()
		}
		
		public function GetTotalLineCount(){
			return this.Count
		}
		
		public function AddNewMessages(Messages:Array){
			var RingI = this.End			
			var MessageCount = Messages.length/3
  

			for(var j=0; j < MessageCount ;j++){
				if(this.RingBuffer[RingI] == undefined){
					this.RingBuffer.push(new ChatMessage(Messages, j*3))
					this.Count++
				}else{
					this.RingBuffer[RingI].ParseMessage(Messages, j*3)
				}

				if(++RingI >= this.MaxSize){
					RingI = 0
				}
				
				
				if(RingI == this.Start){
					this.Start = (RingI+1)%this.MaxSize
				}
			}
			this.End = RingI
			
			return MessageCount
		}
		
		public function Get(index):ChatMessage{
			var i = (this.Start+index)%this.MaxSize

			return this.RingBuffer[i]
		}
		
		public function ReverseGet(index):ChatMessage{
			var i = (this.End-1)-index
			
			if(i < 0){
				i = this.MaxSize+i
			}

			return this.RingBuffer[i]
		}
	}
	
	
	
	