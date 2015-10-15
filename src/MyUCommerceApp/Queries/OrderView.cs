using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class OrderView
	{
		public string CustomerFirstName { get; set; }

		public string CustomerEmail { get; set; }

		public string OrderStatus { get; set; }

		public decimal OrderTotal { get; set; }
	}
}
