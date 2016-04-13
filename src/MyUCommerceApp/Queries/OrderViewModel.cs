using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UCommerce.EntitiesV2;

namespace MyUCommerceApp.BusinessLogic.Queries
{
	public class OrderViewModel
	{
		public string OrderNumber { get; set; }

		public string CustomerFirstName { get; set; }

		public string CustomerEmail { get; set; }

		public decimal OrderTotal { get; set; }

		public string Currency { get; set; }

	}
}
