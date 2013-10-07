using System;
using System.Linq;
using System.Security.Permissions;
using NHibernate.Exceptions;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using NHibernate.Linq;
using UCommerce.Security;

namespace MyUCommerceApp.Test
{

	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING = "Data Source=.;Initial Catalog=utraining;Integrated Security=true;";

		[Test]
		public void Baskets_And_Customers_Last_30_Days()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<PurchaseOrder>()
					.Where(
							// Last 30 days
							x => x.CreatedDate >= DateTime.Now.AddDays(-30)
								// Basket status only
								&& x.OrderStatus.OrderStatusId == 1
								&& x.BillingAddress.EmailAddress != null)
					.Fetch(x => x.BillingAddress)
					.FetchMany(x => x.OrderLines);

				foreach (var order in query.ToList())
				{
					string firstName = order.BillingAddress.FirstName;
					string lastName = order.BillingAddress.LastName;
					foreach (var orderline in order.OrderLines)
					{
						DateTime orderLineCreatedOn = orderline.CreatedOn;
						string productName = orderline.ProductName;
						int quantity = orderline.Quantity;
					}
				}
			}
		}

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var product = session.Query<Product>().First();

				var products = session.Query<Product>()
					.Where(x => x.ProductProperties
						.Any(y => y.ProductDefinitionField.Name == "ShowOnHomepage" && y.Value == "True"))
						.ToList();
			}
		}

		[Test]
		public void JoinProductAndOrderLine()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = from orderline in session.Query<OrderLine>()
							join product in session.Query<Product>()
								on new { orderline.Sku, orderline.VariantSku }
									equals new { product.Sku, product.VariantSku }
							select product;

				query.ToList();

			}
		}

		[Test]
		public void NPlus1()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var products = session.Query<Product>()
					.FetchMany(x => x.ProductProperties)
					.ThenFetch(x => x.ProductDefinitionField)
					.ToList();

				foreach (var product in products)
				{
					var props = product.ProductProperties;
				}
			}
		}

		[Test]
		public void PrefetchWithHQL()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var products = session.CreateQuery(@"
					select p
					from Product p
					join fetch p.ProductProperties")
					.Future<Product>().ToList();
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