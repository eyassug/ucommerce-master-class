using System;
using System.Linq;
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
            //UCommerce.Api.TransactionLibrary.GetBasket().PurchaseOrder;

            //Top level API to query purchaseOrders
            //System.Linq.IQueryable<PurchaseOrder> ordersQuery = UCommerce.EntitiesV2.PurchaseOrder.All();

            //Repository resolved inside PurchaseOrder.All()
            //UCommerce.EntitiesV2.IRepository<PurchaseOrder> ordersRepository 
            //    = ObjectFactory.Instance.Resolve<IRepository<UCommerce.EntitiesV2.PurchaseOrder>>();

            //var ordersQueryFromRepo = ordersRepository.Select().Where(x => x.CompletedDate > new DateTime(2000,10,1)).ToList();

            //ISession is used on the IRepository to do the actual Querying using NHibernate
            //NHibernate.ISession session =
            //    ObjectFactory.Instance.Resolve<ISessionProvider>().GetSession();

            //var sessionQuery = session.Query<UCommerce.EntitiesV2.PurchaseOrder>().Where(x => x.Customer != null).ToList();

            //we can also modify data and save it in the database
            //var product = Product.Get(105);
            //product.Name = "Black and white wonderland!!!";
            //product.Save();

            //Product product = new Product();
            //product.Sku = "Hello world";
            //product.Name = "Hello world name!";
            //product.Save();

            //product.ProductDefinition = new ProductDefinition();

            //product.Save();

            //ISessionProvider sessionProvider = ObjectFactory.Instance.Resolve<ISessionProvider>();

            ////If we use the stateless session we have to keep track of the relations
            ////manually, but performance will be increased.
            //((SessionProvider)sessionProvider).GetStatelessSession().Insert(product);

            //var productRepository = ObjectFactory.Instance.Resolve<IRepository<Product>>();
            //var result = productRepository.Select(new ProductByPropertiesQuery("showOnHomepage", "True")).ToList();

            //N+1 problem
            //fetch solves N+1
            //var orders = PurchaseOrder.All().Fetch(order => order.Customer).ToList();
            //foreach (var order in orders)
            //{
            //    if (order.Customer != null)
            //    {
            //        var firstNameOfCustomer = order.Customer.FirstName;
            //        Console.WriteLine(firstNameOfCustomer);
            //    }
            //    else
            //    {
            //        Console.WriteLine("customer was not present on order with id: " + order.OrderId);
            //    }
            //}


            //var product = Product.Get(105);
            //var variants = Product.All().Where(x => x.ParentProduct == product).ToList();
            //var productRelations = ProductRelation.All().Where(x => x.Product == product).ToList();

            //var productResult = Product.All()
            //    .Where(x => x.ProductId == 105)
            //        .FetchMany(x => x.CategoryProductRelations)
            //        .FetchMany(x => x.Variants)
            //        .FetchMany(x => x.ProductRelations)
            //    .ToList();

            Product product;
            using (var session = ObjectFactory.Instance.Resolve<ISessionProvider>().GetSession())
            {
                product = session.Query<Product>().FetchMany(x => x.Variants).Where(x => x.ProductId == 105).First();
            }

            foreach(var variant in product.Variants)
            {
                Console.WriteLine(variant.Name);
            }
        }
	}
}
