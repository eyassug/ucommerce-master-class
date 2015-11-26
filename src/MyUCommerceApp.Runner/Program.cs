using System.Linq;
using MyUCommerceApp.BusinessLogic.Queries;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;
using UCommerce.Transactions;

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


//			ObjectFactory.Instance.Resolve<IOrderService>().ChangeOrderStatus(order,OrderStatus.Get((int) OrderStatusCode.Cancelled));
		}
	}
}
