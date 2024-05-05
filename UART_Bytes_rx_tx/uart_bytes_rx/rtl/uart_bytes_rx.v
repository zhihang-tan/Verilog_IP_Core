
//多字节接收模块
module uart_bytes_rx
#(
	parameter	integer	BYTES 	 = 5			,				//一次接收字节数，单字节8bit
	parameter	integer	BPS		 = 9600			,				//发送波特率
	parameter 	integer	CLK_FRE	 = 50_000_000					//输入时钟频率
)
(
//系统接口
	input 							sys_clk			,			//系统时钟
	input 							sys_rst_n		,			//系统复位，低电平有效
//用户接口	
	output	[(BYTES * 8 - 1):0] 	uart_bytes_data	,			//接收到的多字节数据，在uart_bytes_vld为高电平时有效
	output							uart_bytes_vld	,			//成功发送所有字节数据后拉高1个时钟周期，代表此时接收的数据有效	
//UART接收	
	input 							uart_rxd					//UART发送数据线rx
);

//reg define
reg	[(BYTES*8-1):0]		uart_bytes_data_reg;					//寄存接收到的多字节数据，先接收低字节，后接收高字节
reg						uart_bytes_vld_reg;						//高电平表示此时接收到的数据有效
reg	[9:0]				byte_cnt;								//发送的字节个数计数(因为懒直接用10bit计数，最大可以表示1024BYTE，大概率不会溢出)			

//wire define
wire	[7:0]			uart_sing_data;							//接收的单个字节数据
wire					uart_sing_done;							//单个字节数据接收完毕信号
	
//对端口赋值
assign uart_bytes_data = uart_bytes_data_reg;
assign uart_bytes_vld  = uart_bytes_vld_reg;

//分别接收各个字节的数据
always @(posedge sys_clk or negedge sys_rst_n)begin		
	if(!sys_rst_n)		
		uart_bytes_data_reg <= 0;												
	else if(uart_sing_done)begin									//接收到一个单字节则将数据右移8bit，实现最先接收的数据在低字节
		if(BYTES == 1)												//单字节就直接接收
			uart_bytes_data_reg <= uart_sing_data;											
		else														//多字节就移位接收
			uart_bytes_data_reg <= {uart_sing_data,uart_bytes_data_reg[(BYTES*8-1)-:(BYTES-1)*8]};														
	end	
	else		
		uart_bytes_data_reg <= uart_bytes_data_reg;				
end

//对接收的字节个数进行计数		
always @(posedge sys_clk or negedge sys_rst_n)begin		
	if(!sys_rst_n)		
		byte_cnt <= 0;		
	else if(uart_sing_done && byte_cnt == BYTES - 1)			//计数到了最大值则清零
		byte_cnt <= 0;										
	else if(uart_sing_done)										//发送完一个单字节则计数器+1
		byte_cnt <= byte_cnt + 1'b1;						
	else		
		byte_cnt <= byte_cnt;			
end

//所有数据接收完毕,拉高接收多字节数据有效信号
always @(posedge sys_clk or negedge sys_rst_n)begin
	if(!sys_rst_n)
		uart_bytes_vld_reg <= 1'b0;
	else if(uart_sing_done && byte_cnt == BYTES - 1)			//所有单字节数据接收完毕
		uart_bytes_vld_reg <= 1'b1;
	else 
		uart_bytes_vld_reg <= 1'b0;
end


//例化串口接收驱动模块
uart_rx #(
	.BPS			(BPS			),		
	.CLK_FRE		(CLK_FRE		)		
)	
uart_rx_inst
(	
	.sys_clk		(sys_clk		),			
	.sys_rst_n		(sys_rst_n		),	
	.uart_rx_done	(uart_sing_done	),			
	.uart_rx_data	(uart_sing_data	),			
	.uart_rxd		(uart_rxd		)
);

endmodule 