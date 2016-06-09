using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;

namespace MyUCommerceApp.Integration
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
