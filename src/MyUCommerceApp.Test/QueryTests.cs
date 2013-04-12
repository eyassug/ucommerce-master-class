using System;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.EntitiesV2.Queries.Catalog;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Security;
using NHibernate.Linq;
using System.Linq;

namespace MyUCommerceApp.Test
{
	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = "Data Source=.;Initial Catalog=utraining2;Integrated Security=true;";

		[Test]
		public void UpdateDatabase()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var order = session.Query<PurchaseOrder>().First();
				order["myprop"] = "myvalue";
				session.SaveOrUpdate(order);
				session.Flush();
			}
		}

		[Test]
		public void NPlusHql()
		{
			var sessionProvider = GetSessionProvider();



			using (var session = sessionProvider.GetSession())
			{
				var cannedQuery = new SingleProductQuery(123);

				var products = cannedQuery.Execute(session);


				var query = session
					.CreateQuery("from PurchaseOrder order")
					.Future<PurchaseOrder>();

				session.CreateQuery(@"select order from PurchaseOrder order
										join fetch order.OrderLines");


			}
		}

		[Test]
		public void NPlusWithQueryOver()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session
					.QueryOver<PurchaseOrder>()
					.Future<PurchaseOrder>();

				session.QueryOver<OrderAddress>().Future<OrderAddress>();

				session.QueryOver<OrderLine>().Future<OrderLine>();

				query.ToList();
			}
		}

		[Test]
		public void NPlus1()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orders = session.Query<PurchaseOrder>()
					.ToList();

				foreach (var order in orders)
				{
					if (order.BillingAddress != null)
						Console.WriteLine(order.BillingAddress.FirstName);
				}


			}
		}

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{

				var query = from product in session.Query<Product>()
							join orderLine in session.Query<OrderLine>()
								on new { product.Sku, product.VariantSku }
								equals new { orderLine.Sku, orderLine.VariantSku }
							select new { orderLine, product };

				query.ToList();


				var orderlines = session.Query<OrderLine>();

				foreach (var orderline in orderlines)
				{
					Product product = session.Query<Product>()
						.Single(x => x.Sku == orderline.Sku
								&& x.VariantSku == orderline.VariantSku);

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
					CacheProvider = "NHibernate.Caches.SysCache2.SysCacheProvider, NHibernate.Caches.SysCache2",
					ConnectionString = CONNECTIONSTRING
				});

			var userServiceStub = MockRepository.GenerateStub<IUserService>();
			userServiceStub.Stub(x => x.GetCurrentUser()).Return(new User("system"));
			userServiceStub.Stub(x => x.GetCurrentUserName()).Return("system");

			var sessionProvider = new SessionProvider(commerceConfigProviderStub, userServiceStub);

			return sessionProvider;
		}
	}
}