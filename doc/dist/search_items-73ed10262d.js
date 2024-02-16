searchNodes=[{"doc":"This module contains functions that are called from other pods via RPC.","ref":"Uaddresses.Rpc.html","title":"Uaddresses.Rpc","type":"module"},{"doc":"Searches for districts using filtering format. Available parameters: Parameter Type Example Description filter list [{:koatuu, :equal, &quot;8500000002&quot;}] order_by list [asc: :inserted_at] or [desc: :status] cursor {integer, integer} or nil {0, 10} Example: iex&gt; Uaddresses.Rpc . search_districts ( [ { :name , :like , &quot;ГАСПРА&quot; } ] , [ desc : :inserted_at ] , { 0 , 10 } ) { :ok , [ %{ id : &quot;5282c084-1015-4404-8d34-9826c502274a&quot; , inserted_at : ~N[2019-03-05 08:55:59.444467] , koatuu : &quot;8500000002&quot; , name : &quot;ГАСПРА&quot; , region_id : &quot;6d6d0186-16f8-484c-9f68-b9395ec91830&quot; , updated_at : ~N[2019-03-05 08:55:59.444475] } ] }","ref":"Uaddresses.Rpc.html#search_districts/3","title":"Uaddresses.Rpc.search_districts/3","type":"function"},{"doc":"Searches for regions using filtering format. Available parameters: Parameter Type Example Description filter list [{:name, :equal, &quot;ГАСПРА&quot;}] order_by list [asc: :inserted_at] or [desc: :status] cursor {integer, integer} or nil {0, 10} Example: iex&gt; Uaddresses.Rpc . search_regions ( [ { :koatuu , :equal , &quot;8500000001&quot; } ] , [ desc : :inserted_at ] , { 0 , 10 } ) { :ok , [ %{ id : &quot;4494f631-2148-4163-96f8-a9c080c78d77&quot; , inserted_at : ~N[2019-03-05 08:55:59.460432] , koatuu : &quot;8500000001&quot; , name : &quot;ГАСПРА&quot; , updated_at : ~N[2019-03-05 08:55:59.460446] } ] }","ref":"Uaddresses.Rpc.html#search_regions/3","title":"Uaddresses.Rpc.search_regions/3","type":"function"},{"doc":"Searches for settlements using filtering format. Available parameters: Parameter Type Example Description filter list [{:mountain_group, :equal, false}] order_by list [asc: :inserted_at] or [desc: :status] cursor {integer, integer} or nil {0, 10} Example: iex&gt; Uaddresses.Rpc . search_settlements ( [ { :koatuu , :equal , &quot;8500000000&quot; } ] , [ asc : :inserted_at ] , { 0 , 10 } ) { :ok , [ %{ district_id : &quot;56cdb8cc-99e1-4b12-b533-d1fa2be4648a&quot; , id : &quot;74fb7249-7f1e-4076-9bfb-bcfed4a8389c&quot; , inserted_at : ~N[2019-03-05 08:55:59.396463] , koatuu : &quot;8500000000&quot; , mountain_group : false , name : &quot;ГАСПРА&quot; , parent_settlement_id : &quot;6683dc0c-230a-4f03-af40-c75303aa865a&quot; , region_id : &quot;ac44eb6d-4354-43cb-9852-45b98806a594&quot; , type : &quot;CITY&quot; , updated_at : ~N[2019-03-05 08:55:59.396469] } ] }","ref":"Uaddresses.Rpc.html#search_settlements/3","title":"Uaddresses.Rpc.search_settlements/3","type":"function"},{"doc":"Searches for districts using filtering format. Available parameters: Parameter Type Example Description filter list [{:settlement_id, :equal, &quot;eea333b5-e26d-4e3e-92e2-2ab37b131502&quot;}] order_by list [asc: :name] or [desc: :name] cursor {integer, integer} or nil {0, 10} Example: iex&gt; Uaddresses.Rpc . search_streets ( [ { :settlement_id , :equal , &quot;eea333b5-e26d-4e3e-92e2-2ab37b131502&quot; } ] , [ desc : :name ] , { 0 , 10 } ) { :ok , [ %{ id : &quot;5282c084-1015-4404-8d34-9826c502274a&quot; , inserted_at : ~N[2019-03-05 08:55:59.444467] , name : &quot;Єрмоленка Володимира&quot; , type : &quot;вул&quot; , updated_at : ~N[2019-03-05 08:55:59.444475] } ] }","ref":"Uaddresses.Rpc.html#search_streets/3","title":"Uaddresses.Rpc.search_streets/3","type":"function"},{"doc":"Get settlement by id iex&gt; Uaddresses.Rpc . settlement_by_id ( &quot;6604341e-2960-404d-aa07-8552720d7222&quot; ) { :ok , %{ district : &quot;some name 0&quot; , district_id : &quot;d37b3c31-809b-4a7d-ace2-8ab826df7b09&quot; , id : &quot;6604341e-2960-404d-aa07-8552720d7222&quot; , koatuu : nil , mountain_group : false , name : &quot;some name&quot; , parent_settlement : nil , parent_settlement_id : &quot;c7f12978-9a30-4609-97c5-c9e5fcb42c57&quot; , region : &quot;some name 0&quot; , region_id : &quot;8e27e7d7-e85c-444d-b2c6-6e3ae98811da&quot; , type : nil } }","ref":"Uaddresses.Rpc.html#settlement_by_id/1","title":"Uaddresses.Rpc.settlement_by_id/1","type":"function"},{"doc":"Update settlement by id Example: iex&gt; Uaddresses.Rpc . update_settlement ( &quot;88e44407-6505-45e3-9cee-b4cae8879aae&quot; , %{ name : &quot;new name&quot; } ) { :ok , %{ district : &quot;some name 14&quot; , district_id : &quot;6273557f-d7ed-4f72-ba99-763262ae5fe2&quot; , id : &quot;88e44407-6505-45e3-9cee-b4cae8879aae&quot; , koatuu : nil , mountain_group : false , name : &quot;new name&quot; , parent_settlement : nil , parent_settlement_id : &quot;4969a8fe-d469-447e-97e5-d5f84725021d&quot; , region : &quot;some name 23&quot; , region_id : &quot;efbd20ec-6f3f-4656-a13a-b12787f45dcb&quot; , type : nil } }","ref":"Uaddresses.Rpc.html#update_settlement/2","title":"Uaddresses.Rpc.update_settlement/2","type":"function"},{"doc":"Validates given addresses. iex&gt; addresses = [ %{ ...&gt; &quot;apartment&quot; =&gt; &quot;23&quot; , ...&gt; &quot;area&quot; =&gt; &quot;Черкаська&quot; , ...&gt; &quot;building&quot; =&gt; &quot;15&quot; , ...&gt; &quot;country&quot; =&gt; &quot;UA&quot; , ...&gt; &quot;region&quot; =&gt; &quot;ЖАШКІВСЬКИЙ&quot; , ...&gt; &quot;settlement&quot; =&gt; &quot;some name&quot; , ...&gt; &quot;settlement_id&quot; =&gt; &quot;aa1d4510-175e-4747-89f1-c68159d07e96&quot; , ...&gt; &quot;settlement_type&quot; =&gt; &quot;CITY&quot; , ...&gt; &quot;street&quot; =&gt; &quot;вул. Ніжинська&quot; , ...&gt; &quot;street_type&quot; =&gt; &quot;STREET&quot; , ...&gt; &quot;type&quot; =&gt; &quot;RESIDENCE&quot; , ...&gt; &quot;zip&quot; =&gt; &quot;02090&quot; ...&gt; } ] ...&gt; Uaddresses.Rpc . validate ( addresses ) :ok Validates given address. iex&gt; address = %{ ...&gt; &quot;apartment&quot; =&gt; &quot;23&quot; , ...&gt; &quot;area&quot; =&gt; &quot;Черкаська&quot; , ...&gt; &quot;building&quot; =&gt; &quot;15&quot; , ...&gt; &quot;country&quot; =&gt; &quot;UA&quot; , ...&gt; &quot;region&quot; =&gt; &quot;ЖАШКІВСЬКИЙ&quot; , ...&gt; &quot;settlement&quot; =&gt; &quot;some name&quot; , ...&gt; &quot;settlement_id&quot; =&gt; &quot;aa1d4510-175e-4747-89f1-c68159d07e96&quot; , ...&gt; &quot;settlement_type&quot; =&gt; &quot;CITY&quot; , ...&gt; &quot;street&quot; =&gt; &quot;вул. Ніжинська&quot; , ...&gt; &quot;street_type&quot; =&gt; &quot;STREET&quot; , ...&gt; &quot;type&quot; =&gt; &quot;RESIDENCE&quot; , ...&gt; &quot;zip&quot; =&gt; &quot;02090&quot; ...&gt; } ...&gt; Uaddresses.Rpc . validate ( address ) :ok","ref":"Uaddresses.Rpc.html#validate/1","title":"Uaddresses.Rpc.validate/1","type":"function"},{"doc":"","ref":"Uaddresses.Rpc.html#t:district/0","title":"Uaddresses.Rpc.district/0","type":"type"},{"doc":"","ref":"Uaddresses.Rpc.html#t:region/0","title":"Uaddresses.Rpc.region/0","type":"type"},{"doc":"","ref":"Uaddresses.Rpc.html#t:settlement/0","title":"Uaddresses.Rpc.settlement/0","type":"type"},{"doc":"","ref":"Uaddresses.Rpc.html#t:settlement_rpc/0","title":"Uaddresses.Rpc.settlement_rpc/0","type":"type"},{"doc":"","ref":"Uaddresses.Rpc.html#t:street/0","title":"Uaddresses.Rpc.street/0","type":"type"}]