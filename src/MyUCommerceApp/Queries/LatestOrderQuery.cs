﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NHibernate;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries;

namespace MyUCommerceApp.Queries
{
	public class LatestOrderQuery : ICannedQuery<PurchaseOrder>
	{
		public IEnumerable<PurchaseOrder> Execute(ISession session)
		{
			var purchaseOrder = session.Query<PurchaseOrder>()
				.OrderByDescending(x => x.CompletedDate)
				.First();

			return new[] {purchaseOrder};
		}
	}
}
