
//串口多字节发送测试模块
module uart_bytes_tx_test(
//系统接口
	input 				sys_clk			,					//主时钟
	input 				sys_rst_n		,	                //低电平有效的复位信号
//UART发送线	
	output  			uart_txd							//UART发送线
);

localparam	integer		BYTES 	 = 5			;			//发送的字节数，单字节8bit
localparam	integer		BPS		 = 115200		;			//发送波特率
localparam 	integer		CLK_FRE	 = 50_000_000	;			//输入时钟频率
localparam	integer		CNT_MAX  = 50_000_000  	;			//发送时间间隔，1秒

reg		[31:0]			cnt_time; 
reg						uart_bytes_en;						//发送使能，当其为高电平时，代表此时需要发送数据		
reg		[BYTES*8-1 :0] 	uart_bytes_data;					//需要通过UART发送的数据，在uart_bytes_en为高电平时有效
 
//1s计数模块，每隔1s发送一个数据和拉高发送使能信号一次，数据从初始值开始递增1
always @(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)begin
		cnt_time <= 'd0;
		uart_bytes_en <= 1'd0;
		uart_bytes_data <= 40'h9a_78_56_34_12;				//初始数据
	end
	else if(cnt_time == (CNT_MAX - 1'b1))begin
		cnt_time <= 'd0;
		uart_bytes_en <= 1'd1;								//拉高发送使能
		uart_bytes_data <= uart_bytes_data + 1'd1;			//发送数据累加1
	end
	else begin
		cnt_time <= cnt_time + 1'd1;
		uart_bytes_en <= 1'd0;
		uart_bytes_data <= uart_bytes_data; 
	end
end

//例化串口多字节发送模块
uart_bytes_tx
#(
	.BYTES 	 			(BYTES 				),				
	.BPS				(BPS				),				
	.CLK_FRE			(CLK_FRE			)				
)		
uart_bytes_tx_inst		
(		
		
	.sys_clk			(sys_clk			),			
	.sys_rst_n			(sys_rst_n			),				                                    
	.uart_bytes_data	(uart_bytes_data	),			
	.uart_bytes_en		(uart_bytes_en		),			                                   
	.uart_bytes_done	(					),			
	.uart_txd			(uart_txd			)			
);

endmodule