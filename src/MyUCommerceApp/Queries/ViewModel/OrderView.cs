using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyUCommerceApp.BusinessLogic.Queries.ViewModel
{
	public class OrderView
	{
		public string CustomerFirstName { get; set; }

		public string CustomerLastName { get; set; }

		public string CustomerEmail { get; set; }

		public decimal OrderTotal { get; set; }

		public string OrderNumber { get; set; }

		public string OrderStatus { get; set; }

		public string StoreName { get; set; }
	}
}
