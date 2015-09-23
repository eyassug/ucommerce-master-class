using System;
using System.Linq;
using System.Security.Cryptography.X509Certificates;
using MyUCommerceApp.BusinessLogic.Queries;
using NHibernate.Linq;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure;

namespace MyUCommerceApp.Integration
{
	class Program
	{
		static void Main(string[] args)
		{
		    Session();
		}

	    public static void Session()
	    {
            var sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();

	        using (var session = sessionProvider.GetSession())
	        {
	            session.CreateQuery("select p from Product p").Future<Product>();

	            session.CreateQuery("select p from Product p left join p.Variants").Future<Product>();
	        }

        }

	    public static void Join()
	    {
	        var lineRepo = ObjectFactory.Instance.Resolve<IRepository<OrderLine>>();
	        var productRepo = ObjectFactory.Instance.Resolve<IRepository<Product>>();

	        var query = from orderline in lineRepo.Select()
	            join product in productRepo.Select() on 
                    new { orderline.Sku, orderline.VariantSku } equals new { product.Sku, product.VariantSku }
	            select new {Product = product, OrderLine = orderline};

	        var orderlinesAndProducts = query.ToList();
	    }

	    public static void NPlusOne_Avoiding_Large_Cartesian_Product()
	    {
            var orderRepository = ObjectFactory
                       .Instance
                       .Resolve<IRepository<PurchaseOrder>>();

	        var addressesRepository = ObjectFactory
                .Instance.Resolve<IRepository<OrderAddress>>();

            var orders = orderRepository
                .Select()
                .Where(x => x.CreatedDate > new DateTime(2015, 08, 01))
                .ToFuture();

	        addressesRepository
	            .Select()
	            .Where(x => x.PurchaseOrder.CreatedDate > new DateTime(2015, 08, 01))
                .ToFuture();

            foreach (var order in orders.ToList())
            {
                if (order.BillingAddress == null) continue;

                Console.WriteLine(order.BillingAddress.FirstName);
            }
        }

	    public static void NPlusOne()
	    {
            var orderRepository = ObjectFactory
                .Instance
                .Resolve<IRepository<PurchaseOrder>>();

            var orders = orderRepository
                .Select()
                .Fetch(x => x.BillingAddress)
                .Where(x => x.CreatedDate > new DateTime(2015, 08, 01))
                .ToList();

	        foreach (var order in orders)
	        {
	            if (order.BillingAddress == null) continue;

                Console.WriteLine(order.BillingAddress.FirstName);
	        }
        }

	    public static void DynamicProperties()
	    {
            var repo = ObjectFactory
                .Instance
                .Resolve<IRepository<Product>>();

            var productsForRepo = repo.Select().Where(
                x => x.ProductProperties.Any(
                    y => y.ProductDefinitionField.Name == "ShowOnHomepage" && y.Value == "true"))
                .Take(128)
                .ToList();
        }

	    public void FirstQuery()
        {
            var orderRepository = ObjectFactory
                .Instance
                .Resolve<IRepository<PurchaseOrder>>();

            var order = orderRepository
                .Select()
                .Where(x => x.CreatedDate > new DateTime(2015, 08, 01))
                .ToList();
        }
	}
}
