using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyUCommerceApp.BusinessLogic.Integration
{
	public interface IErpConnector
	{
		void ExportOrderToErp(string content);
	}
}
