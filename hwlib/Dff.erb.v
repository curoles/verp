/**@file
 * @brief     D Flip Flop VERP HWLib
 * @author    Igor Lesik
 * @copyright Igor Lesik 2014
 *
 * License    Distributed under the Boost Software License, Version 1.0.
 *            (See  http://www.boost.org/LICENSE_1_0.txt)
 */

%# Dff parameters:
% name         ||= 'Dff'
% posedge      ||= true
% gated_clk    ||= false
% enabled_data ||= false
% has_reset    ||= false
% async_reset  ||= false
%#
% edge = posedge ? 'posedge' : 'negedge'

/** D flip-flop module <%=name%>
 *  Clock edge : <%=edge%>
 *  Gated clock: <%=gated_clk.to_s%>
 *  Data enable: <%=async_reset.to_s%>
 *  Reset      : <%=if has_reset then "async=#{async_reset}" else "no" end%>
 */
module <%=name%> 
#(parameter WIDTH = 1)
(
   input  [WIDTH-1:0] d
  ,input              clk
  ,output reg [WIDTH-1:0] q
<%if gated_clk%>  ,input clk_enable<%;end%>
<%if enabled_data%>  ,input enable<%;end%>
);

  wire clk_signal = clk<%if gated_clk then%> && clk_enable<%;end%>;

  always @(<%=edge%> clk_signal<%if async_reset%> or <%=edge%> reset<%;end%>)
  begin
<%if has_reset%>    if (reset) q[WIDTH-1:0] <= 'h0; else<%;end-%>
    <%if enabled_data%>if (enable) <%;end%>q[WIDTH-1:0] <= d[WIDTH-1:0];
  end

endmodule

