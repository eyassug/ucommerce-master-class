using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MyUCommerceApp.Queries;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;

namespace MyUCommerceApp.Runner
{
	class Program
	{
		static void Main(string[] args)
		{
			var order = ObjectFactory
				.Instance
				.Resolve<IRepository<PurchaseOrder>>()
				.Select(new LatestOrderQuery()).First();
		}
	}
}
