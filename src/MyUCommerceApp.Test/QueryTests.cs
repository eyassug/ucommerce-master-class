using System.Collections.Generic;
using System.Linq;
using Castle.Windsor.Installer;
using MyUCommerceApp.Queries;
using NHibernate;
using NHibernate.Transform;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries.Catalog;
using UCommerce.Infrastructure;
using UCommerce.Infrastructure.Configuration;
using NHibernate.Linq;
using UCommerce.Runtime;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{

	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = "Data Source=.;Initial Catalog=u6;Integrated Security=true;";

		public class ProductSku
		{
			public string Sku { get; set; }
			public string VariantSku { get; set; }
		}

		[Test]
		public void ProductQuery()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var result = session.CreateQuery(
					@"
					SELECt 
						p.Sku AS Sku,
						p.VariantSku AS VariantSku
					FROM Product p
				")
					.SetResultTransformer(new AliasToBeanResultTransformer(typeof(ProductSku)))
					.List();

			}
		}

		[Test]
		public void QueryingHql()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery(
				@"
					select p from Product p
					left join fetch p.Variants 
				").Future<Product>().ToList();
			}
		}

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>().First();
			}
		}

		[Test]
		public void LazyLoadingTest()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				//Billing address are lazy loaded and will first be 
				//loaded from the database once we access the object properties or methods.
				var orders = session.Query<PurchaseOrder>().ToList();

				//once we loop the orders we will get a N+1 problem 
				//as we will get a database connection per order, as it needs 
				//to fetch the billing address from the database as it is lazy loaded.
				//We need a strategy to ensure billing address are loaded in the same go.
				foreach (var purchaseOrder in orders)
				{
					//Billing address will be a proxy object if billing address 
					//exists for the order. We can check for the null reference
					//since this is only asking if the object are initialized 
					//In case the BillingAddress exists in the database, the 
					//object are initialized as a proxy object.
					if (purchaseOrder.BillingAddress != null)
					{
						var firstName = purchaseOrder.BillingAddress.FirstName;
					}
				}
			}
		}

		[Test]
		public void ProductsOnHomePageQuery()
		{
			var sessionProvider = GetSessionProvider();
			var productsOnHomePageQuery = new ProductsOnHomePageQuery();
			using (var session = sessionProvider.GetSession())
			{

				var result = productsOnHomePageQuery.Execute(session);
			}
		}

		[Test]
		public void JoiningProductAndOrderLine()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = from orderLine in session.Query<OrderLine>()
							join product in session.Query<Product>()
								on new { orderLine.Sku, orderLine.VariantSku }
								equals new { product.Sku, product.VariantSku }
							select new { product, orderLine };

				var result = query.ToList();
			}
		}

		[Test]
		public void FetchingFromOrders()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orders = session.Query<PurchaseOrder>()
					.Fetch(order => order.BillingAddress)
					.ToList();

				foreach (var purchaseOrder in orders)
				{
					//Billing address will be a proxy object if billing address 
					//exists for the order. We can check for the null reference
					//since this is only asking if the object are initialized 
					//In case the BillingAddress exists in the database, the 
					//object are initialized as a proxy object.
					if (purchaseOrder.BillingAddress != null)
					{
						var firstName = purchaseOrder.BillingAddress.FirstName;
					}
				}
			}
		}

		private SessionProvider GetSessionProvider()
		{
			var commerceConfigProviderStub = MockRepository.GenerateStub<CommerceConfigurationProvider>();
			commerceConfigProviderStub
				.Stub(x => x.GetRuntimeConfiguration())
				.Return(new RuntimeConfigurationSection
				{
					EnableCache = true,
					CacheProvider = "NHibernate.Caches.SysCache.SysCacheProvider, NHibernate.Caches.SysCache",
					ConnectionString = CONNECTIONSTRING
				});

			var userServiceStub = MockRepository.GenerateStub<IUserService>();
			userServiceStub.Stub(x => x.GetCurrentUser()).Return(new User("system"));
			userServiceStub.Stub(x => x.GetCurrentUserName()).Return("system");

			var sessionProvider = new SessionProvider(commerceConfigProviderStub, userServiceStub, new List<IContainsNHibernateMappingsTag>());

			return sessionProvider;
		}
	}
}