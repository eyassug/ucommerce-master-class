using System;
using System.Linq;
using NUnit.Framework;
using Rhino.Mocks;
using UCommerce.Api;
using UCommerce.EntitiesV2;
using UCommerce.Infrastructure.Configuration;
using UCommerce.Security;
using NHibernate.Linq;

namespace MyUCommerceApp.Test
{
	[TestFixture]
	public class QueryTests
	{
		private const string CONNECTIONSTRING 
			= "Data Source=.;Initial Catalog=utraining;Integrated Security=true;";

		[Test]
		public void Hql()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var query = session.CreateQuery(@"from Product p")
						.Future<Product>();

				session.CreateQuery(@"from Product p
							left join fetch p.Variants")
						.Future<Product>();

				query.ToList();

			}
		}

		[Test]
		public void N_Plus_1()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var products = session.Query<Product>()
					.FetchMany(x => x.Variants)
					.ThenFetch(x => x.ProductDefinition)
					.ToList();
				
				foreach (var product in products)
				{
					Console.WriteLine(product.Name);
					foreach (var variant in product.Variants)
					{
						Console.WriteLine(variant.Name);
					}
				}
			}

		}

		[Test]
		public void Join_Product_And_OrderLine()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var q = from product in session.Query<Product>()
						join orderLine in session.Query<OrderLine>()

						on new {product.Sku, product.VariantSku}
						equals new {orderLine.Sku, orderLine.VariantSku}
				        
						select new
							       {
								       Product = product, 
									   OrderLine = orderLine
							       };

				q.ToList();

				Assert.That(q.Count(), Is.EqualTo(5));
			}

		}

		[Test]
		public void Query_By_Custom_Product_Property()
		{
			var sessionProvider = GetSessionProvider();

			using (var session = sessionProvider.GetSession())
			{
				var allQuery = session.Query<Product>().ToList();

				IQueryable<Product> q1 = session.Query<Product>()
					.Where(x => x.Rating > 4);

				IQueryable<Product> query
					= session.Query<Product>()
					.Where(x => x.ProductProperties.Any(
						y => y.ProductDefinitionField.Name == "ShowOnHomepage" 
							&& y.Value == "True"));

				query.ToList();

				Assert.That(query.Count(), Is.GreaterThan(0));
			}
		}

		private SessionProvider GetSessionProvider()
		{
			var commerceConfigProviderStub 
				= MockRepository.GenerateStub<CommerceConfigurationProvider>();
			commerceConfigProviderStub
				.Stub(x => x.GetRuntimeConfiguration())
				.Return(new RuntimeConfigurationSection
				{
					EnableCache = true,
					CacheProvider = "NHibernate.Caches.SysCache2.SysCacheProvider, NHibernate.Caches.SysCache2",
					ConnectionString = CONNECTIONSTRING
				});

			var userServiceStub = MockRepository.GenerateStub<IUserService>();

			var sessionProvider = new SessionProvider(
				commerceConfigProviderStub, 
				userServiceStub);

			return sessionProvider;
		}
	}
}