using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MyUCommerceApp.BusinessLogic.Queries.ViewModel
{
	public class OrderViewModel
	{
		public string OrderNumber { get; set; }

		public string CustomerFirstName { get; set; }

		public string Email { get; set; }

		public decimal OrderTotal { get; set; }

		public string Currency { get; set; }
	}
}
