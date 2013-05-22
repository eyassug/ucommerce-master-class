using System;
using System.Diagnostics;
using System.Linq;
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
		private const string CONNECTIONSTRING = "Data Source=.;Initial Catalog=utraining3;Integrated Security=true;";

		[Test]
		public void Test()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var orderQuery = session.Query<PurchaseOrder>()
					.Where(x => x.CreatedDate >= new DateTime(2013, 5, 7))
					.OrderByDescending(x => x.CreatedDate).Cacheable();
				
				var orderQuery1 = from purchaseOrder in session.Query<PurchaseOrder>()
								  where purchaseOrder.CreatedDate >= new DateTime(2013, 5, 7)
								  && purchaseOrder.Customer.FirstName == "Søren"
								  orderby purchaseOrder.CreatedDate
				                  select purchaseOrder;
			}
		}

		[Test]
		public void Join_On_Multiple_Properties()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = from orderLine in session.Query<OrderLine>()
				            join product in session.Query<Product>()
					            on new {orderLine.Sku, orderLine.VariantSku} equals
					            new {product.Sku, product.VariantSku}
				            select new {orderLine, product};
			}
		}

		[Test]
		public void Query_Product_By_Custom_Property()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.Query<Product>()
				    .Where(x => x.ProductProperties.Any(
						    y => y.ProductDefinitionField.Name == "ShowOnHomepage" && y.Value == "True"));
			}
		}

		[Test]
		public void N_Plus_1()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var products = session.Query<Product>()
					.Fetch(x => x.ParentProduct)
					.FetchMany(x => x.ProductProperties)
					.ThenFetch(x => x.ProductDefinitionField)
					.ToList();

				foreach (var product in products)
				{
					//Debug.WriteLine(product.Sku);
					Debug.WriteLine(product.ProductProperties.Count());
				}
			}
		}

		[Test]
		public void Hql_Prefetching()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery(@"select p from Product p")
					.Future<Product>();

				session.CreateQuery(@"from PurchaseOrder")
					.Future<PurchaseOrder>();

				query.ToList();
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