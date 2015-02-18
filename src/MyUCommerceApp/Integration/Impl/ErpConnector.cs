using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace MyUCommerceApp.BusinessLogic.Integration.Impl
{
	public class ErpConnector : IErpConnector
	{
		private readonly string _connectionString;

		public ErpConnector(string connectionString)
		{
			_connectionString = connectionString;
		}

		public void ExportOrderToErp(string content)
		{
			File.AppendAllText(_connectionString,content + "\r\n");
		}
	}
}
