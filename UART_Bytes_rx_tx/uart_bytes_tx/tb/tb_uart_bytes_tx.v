`timescale 1ns/1ns	//定义时间刻度


module tb_uart_bytes_tx();

localparam	integer	BYTES    = 5			;		//一次发送的字节个数

localparam	integer	BPS 	 = 230400		;		//波特率
localparam	integer	CLK_FRE  = 50_000_000	;		//系统频率50M

reg 						sys_clk			;		//系统时钟
reg 						sys_rst_n		;		//系统复位，低电平有效	
reg	[(BYTES * 8 - 1):0] 	uart_bytes_data	;		//需要通过UART发送的多字节数据，在uart_bytes_en为高电平时有效
reg							uart_bytes_en	;		//发送有效，当其为高电平时，代表此时需要发送的数据有效
wire						uart_bytes_done	;		//成功发送完所有BYTE数据后拉高1个时钟周期
wire 						uart_txd		;		//UART发送数据线

initial begin	
	sys_clk <=1'b0;	
	sys_rst_n <=1'b0;
	uart_bytes_en <=1'b0;
	uart_bytes_data <= 0;
	#80 											//系统开始工作
	sys_rst_n <=1'b1;	
//*******************************************************************************		
//第1次发送随机数据
	#90 												//发送1次随机的多字节数据
		uart_bytes_en <=1'b1;	
		uart_bytes_data <= {$random};					//生成随机数据
	#20 
		uart_bytes_en <=1'b0;	
	wait(uart_bytes_done);								//等待其发送完
//*******************************************************************************		
//*******************************************************************************			
//第2次发送随机数据
	#20 
		uart_bytes_en <=1'b1;	
		uart_bytes_data <= {$random};					//发送1次随机的多字节数据
	#20 
		uart_bytes_en <=1'b0;	
	wait(uart_bytes_done);								//等待其发送完
//*******************************************************************************		
//第3次发送随机数据	
	#20 
		uart_bytes_en <=1'b1;	
		uart_bytes_data <= {$random};					//发送1次随机的多字节数据
	#20 
		uart_bytes_en <=1'b0;	
	wait(uart_bytes_done);								//等待其发送完
//*******************************************************************************		
	#1000 $finish();			//结束仿真
end

always #10 sys_clk=~sys_clk;	//设置主时钟，20ns,50M

//例化多字节发送模块
uart_bytes_tx #(
	.BYTES				(BYTES				),
	.BPS				(BPS				),		
	.CLK_FRE			(CLK_FRE			)		
)			
uart_bytes_tx_inst(			
	.sys_clk			(sys_clk			),			
	.sys_rst_n			(sys_rst_n			),
		
	.uart_bytes_data	(uart_bytes_data	),			
	.uart_bytes_en		(uart_bytes_en		),
	
	.uart_bytes_done	(uart_bytes_done	),
	.uart_txd			(uart_txd			)	
);

endmodule 