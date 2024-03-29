SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
--Modificado

CREATE PROC [dbo].[AjusteAnual] AS

DECLARE

@Clientes float, 
@SaldoCte float, @SaldoCte12 float, @InteresesPorCobrar float, @CredilanaPrestamo float,
@Deudores float,
@ChequesDev float, 
@BancosNac float, 
@Inversiones float, 
@SaldosAFavor float, 
@TotalCreditos float,
@Proveedores float,
@Acreedores float, 
@IVAPorPagar float, 
@Documentos float, 
@Creditos float, 
@CreditosLP float, 
@InteresesD float, 
@TotalDeudas float, 
@Diferencia float,
@FactorAjuste float, 
@Producto float,
--@Total float,
@FechaInicial datetime,
@Ano int, @Mes int,
@AnoAux int, @MesAux int, @MesAntes int,
@FactorAjusteAntes float, @AjusteAntes int, @FactorAjusteCalculado float, @INPC float, @INPC1 float
SOGARE
DECLARE @TablaAjusteAnual TABLE (Ejercicio int, Periodo int, Clientes Float, Deudores Float, ChequesDevueltos Float, 
						BancosNac Float, Inversiones Float, SaldosAFavor Float, TotalCreditos float,Proveedores Float, 
						Acreedores Float, IVAPorPagar Float, Documentos Float, CreditosBan Float, CreditosBanLP Float, 
						InteresesDevengados Float, TotalDeudas float, Diferencia float, FactorAjuste Float, Producto float) 


DECLARE @TablaAjustePeriodo TABLE (Ejercicio int, Clasificacion varchar(20),Concepto varchar(20), Periodo1 float, Periodo2 float, Periodo3 float, Periodo4 float,
						Periodo5 float, Periodo6 float, Periodo7 float, Periodo8 float, Periodo9 float, Periodo10 float,
						Periodo11 float,Periodo12 float, Total float)


SELECT @FechaInicial= (SELECT MIN(FechaEmision) FROM Cont WHERE Estatus='CONCLUIDO')

SET @Mes= MONTH(GETDATE()) --month('2008-01-12')
set lol
SET @mesantes=0

/*

select * from @tablaajusteperiodo*/

IF (@Mes <> 1) BEGIN
 SET @MesAux= MONTH(GETDATE()) -1 SET @AnoAux=YEAR(GETDATE()) SET @AjusteAntes= MONTH(GETDATE()) -2 
END -- if mes <> 1


IF (@Mes = 1) BEGIN
	SET @MesAux = 12 SET @AnoAux=YEAR(GETDATE()) -1 -- set @mesantes=0
	SET @AjusteAntes= Month(dateadd(mm, 0, dateadd(dd,-1,dateadd(yy, datediff(yy,0, getdate()), 0))))-1
END  -- en if mes =1




WHILE @MesAux > 0 BEGIN
	
	SELECT @SaldoCte=(((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock)
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov not in 
										('Solicitud Cheque', 'Solicitud Deposito','Cancela Credilana','Cancela Prestamo','Seguro Vida',
										'Seguro Auto','Cancela Seg Auto','Cancela Seg Vida', 'Aplicacion Saldo','Aplicacion','Cobro','Cobro Instituciones') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null)/* AND A.Modulo = 'CXC'*/ AND 
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))) +

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock)--, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov IN 
										('Aplicacion','Cobro') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND /*A.Modulo = 'CXC' AND */
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) 
										/*C.ID = D.id and D.Aplica = cx.Mov and d.AplicaId = cx.MovId and cx.id = XD.id and 
										XD.Aplica not in ('Seguro Vida','Seguro Auto')))*/ +

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock), cxc Y With(NoLock), cxc Z With(NoLock) --, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov IN 
										('Cobro Instituciones') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND /*A.Modulo = 'CXC' AND */
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto') 
										and x.origen = y.mov and x.origenid = y.movid and y.origen = z.mov and y.origenid = z.movid and
										z.mov not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) -


/**** se agrego el mov de engache para el saldo del cliente, funciona igual que el anticipo contado, etc, pero solo se consideraran
	cuando no se haya emitido la factura  *****/

					 ISNULL((	SELECT	SUM(A.Abono) 
								FROM	Auxiliar A With(NoLock), CxC With(NoLock), Venta VentaP With(NoLock), Condicion Cond With(NoLock)
								WHERE	CxC.ID=A.ModuloID AND CxC.Mov IN ('Enganche','Anticipo Contado','Anticipo Mayoreo','Apartado') 
										AND CxC.Referencia= LTRIM(RTRIM(VentaP.Mov)) + ' ' + LTRIM(RTRIM(VentaP.MovID)) 
										AND CxC.Estatus='CONCLUIDO' /*AND A.Modulo = 'CXC'*/
										AND VentaP.Estatus Not in('CANCELADO')
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))
										AND VentaP.Condicion=Cond.Condicion), 0) +

/**** se agrego el mov de Devolucion Engache para el saldo del cliente, funciona igual que las demas devoluciones  *****/
							  
					(ISNULL((	SELECT SUM(A.Cargo) 
								FROM	Auxiliar A With(NoLock), CxC With(NoLock) 
								WHERE	CxC.ID=A.ModuloID /*AND A.Modulo = 'CXC'*/
										AND CxC.Mov IN ('Dev Anticipo Contado', 'Dev Anticipo Mayoreo', 'Devolucion Apartado', 'Devolucion Enganche') 
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))), 0)))

-- Se acabaron las modificaciones del enganche 01
------------------------------------------------------------------------------------------------------------------------------------
	SELECT @SaldoCte12=	(((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock)
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov not in 
										('Solicitud Cheque', 'Solicitud Deposito','Cancela Credilana','Cancela Prestamo','Seguro Vida',
										'Seguro Auto','Cancela Seg Auto','Cancela Seg Vida', 'Aplicacion Saldo','Aplicacion','Cobro','Cobro Instituciones')  AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) AND A.Modulo = 'CXC'
										AND A.Aplica NOT IN ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') AND
										A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))) +

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock)--, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Aplicacion','Cobro')  AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) AND A.Modulo = 'CXC'
										AND A.Aplica NOT IN ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') AND
										A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))  
										AND x.origen not in ('Cancela Credilana','Cancela Prestamo','Seguro Vida','Seguro Auto')))
										/*C.ID = D.id and D.Aplica = cx.Mov and d.AplicaId = cx.MovId and cx.id = XD.id and 
										XD.Aplica not in ('Seguro Vida','Seguro Auto')))*/ +

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C With(NoLock), Auxiliar A With(NoLock), CXC X With(NoLock), cxc Y With(NoLock), cxc Z With(NoLock)--, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Cobro Instituciones')  AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) AND A.Modulo = 'CXC'
										AND A.Aplica NOT IN ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') AND
										A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))  
										AND x.origen not in ('Cancela Credilana','Cancela Prestamo','Seguro Vida','Seguro Auto')
										and x.origen = y.mov and x.origenid = y.movid and y.origen = z.mov and y.origenid = z.movid and
										z.mov not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) -

/**** se agrego el mov de engache para el saldo del cliente, funciona igual que el anticipo contado, etc, pero solo se consideraran
	cuando no se haya emitido la factura  *****/


						ISNULL((SELECT	SUM(A.Abono) 
								FROM	Auxiliar A With(NoLock), CxC With(NoLock), Venta VentaP With(NoLock), Condicion Cond With(NoLock)
								WHERE	CxC.ID=A.ModuloID AND CxC.Mov IN ('Enganche','Anticipo Contado', 'Anticipo Mayoreo', 'Apartado') 
										AND CxC.Referencia= LTRIM(RTRIM(VentaP.Mov)) + ' ' + LTRIM(RTRIM(VentaP.MovID)) 
										AND CxC.Estatus='CONCLUIDO' AND A.Modulo = 'CXC'
										AND VentaP.Estatus not in('CANCELADO')
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))
										AND VentaP.Condicion=Cond.Condicion AND 
										(ISNULL(Cond.DANumeroDocumentos, ISNULL(Cond.Meses, ( Cond.DiasVencimiento/30) )) >= 12 )), 0) +



					(ISNULL	((	SELECT	SUM(A.Cargo) 
								FROM	Cxc X With(NoLock), Cxc C With(NoLock), Venta V With(NoLock), Condicion Cond With(NoLock), Auxiliar A With(NoLock)  
								WHERE	C.Mov IN ('Dev Anticipo Contado', 'Dev Anticipo Mayoreo', 'Devolucion Apartado', 'Devolucion Enganche') 
										and ltrim(X.Mov) + ' ' +  ltrim(X.MovId) = C.RefAnticipoMAVI and ltrim(V.Mov) + ' ' +  ltrim(V.MovId) = X.Referencia
										AND V.Condicion=Cond.Condicion AND
										((ISNULL(Cond.DANumeroDocumentos,ISNULL(Cond.Meses,(Cond.DiasVencimiento/30))) >= 12))
										and C.ID=A.ModuloID AND A.Modulo = 'CXC'
										AND C.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) ), 0)))



	SELECT @InteresesPorCobrar=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('110-99-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @Clientes=(SELECT ISNULL(@SaldoCte,0) - ISNULL(@SaldoCte12,0) - ISNULL(@InteresesPorCobrar,0) )
-- select ISNULL(@SaldoCte,0),  ISNULL(@SaldoCte12,0),  ISNULL(@InteresesPorCobrar,0)

	SELECT @Deudores=(SELECT ISNULL(SUM(D.Debe), 0) - ISNULL(SUM(D.Haber), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('112-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @ChequesDev=(SELECT ISNULL(SUM(D.Debe), 0) - ISNULL(SUM(D.Haber), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('103-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))
	
	SELECT @BancosNac=(SELECT ISNULL(SUM(D.Debe), 0) - ISNULL(SUM(D.Haber), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('101-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @Inversiones=(SELECT ISNULL(SUM(D.Debe), 0) - ISNULL(SUM(D.Haber), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('104-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @SaldosAFavor=(SELECT ISNULL(SUM(D.Debe), 0) - ISNULL(SUM(D.Haber), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('116-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))		

	SELECT @Proveedores=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('203-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @Acreedores=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('206-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @IVAPorPagar=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('201-01-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @Documentos=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('202-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @Creditos=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('208-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @CreditosLP=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('210-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))

	SELECT @InteresesD=(SELECT ISNULL(SUM(D.Haber), 0) - ISNULL(SUM(D.Debe), 0) FROM Cont C With(NoLock), ContD D With(NoLock) 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('207-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))) 

	SELECT @FactorAjuste =(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual = 'INPC' AND Ejercicio = @AnoAux 
							AND  Periodo = @MesAux )
		
	IF (@Mes <> 1)
	BEGIN
		IF (@AjusteAntes >=1 ) BEGIN
			SELECT @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual = 'INPC' AND Ejercicio = @AnoAux 
							AND  Periodo = @AjusteAntes )  END 

		IF (@AjusteAntes = 0) BEGIN
			SET @AjusteAntes=12
			SELECT @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual = 'INPC' AND Ejercicio = @AnoAux -1
							AND  Periodo = @AjusteAntes )  END 
	END

	IF (@Mes = 1)
	BEGIN
		IF (@AjusteAntes <> 0) BEGIN
			SELECT @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual = 'INPC' AND Ejercicio = @anoaux 
							AND  Periodo = @ajusteantes )  END -- mes 1
		IF (@AjusteAntes = 0) BEGIN
			set @AjusteAntes=12
			select @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual = 'INPC' AND Ejercicio = @anoaux -1
							AND  Periodo = @ajusteantes )  END
	END	


	SELECT @TotalCreditos=(SELECT ISNULL(@Clientes, 0) + ISNULL(@Deudores, 0) + ISNULL(@ChequesDev,0) + ISNULL(@BancosNac,0) + 
							ISNULL(@Inversiones,0) + ISNULL(@SaldosAFavor,0) )
	SELECT @TotalDeudas= (SELECT ISNULL(@Proveedores,0) + ISNULL(@Acreedores,0) +  ISNULL(@IVAPorPagar,0) + ISNULL(@Documentos,0) + 
							ISNULL(@Creditos,0) +ISNULL(@CreditosLP,0) + ISNULL(@InteresesD,0) )
	SELECT @Diferencia=(SELECT ISNULL(@TotalCreditos,0) - ISNULL(@TotalDeudas,0))
	SELECT @FactorAjusteCalculado=(SELECT ROUND(CONVERT(float, SUBSTRING(CONVERT(char, @FactorAjuste / @FactorAjusteAntes -1), 1, 10)), 6))
	SELECT @Producto=(SELECT ISNULL(@Diferencia,0) * ISNULL(@FactorAjusteCalculado,0))





	INSERT INTO @TablaAjusteAnual ( Ejercicio, Periodo, Clientes, Deudores, ChequesDevueltos, BancosNac, Inversiones, 
						SaldosAFavor, TotalCreditos, Proveedores, Acreedores, IVAPorPagar, Documentos, CreditosBan, 
						CreditosBanLP, InteresesDevengados, TotalDeudas, Diferencia, FactorAjuste, Producto ) 
		VALUES (@AnoAux, @MesAux, @Clientes, @Deudores, @ChequesDev, @BancosNac, @Inversiones, @SaldosAFavor, @TotalCreditos,
				@Proveedores, @Acreedores, @IVAPorPagar, @Documentos, @Creditos, @CreditosLP, @InteresesD, @TotalDeudas,
				@Diferencia, @FactorAjusteCalculado, @Producto) 

	SET @MesAux = @MesAux-1
	SET @MesAntes = @MesAntes -1
	SET @AjusteAntes = @AjusteAntes -1 
END

--SELECT * FROM @TablaAjusteAnual

--END

	
/*
IF (@Mes = 1) BEGIN
	SET @MesAux = 12 SET @AnoAux=YEAR(GETDATE()) -1 -- set @mesantes=0
	SET @AjusteAntes= Month(dateadd(mm, 0, dateadd(dd,-1,dateadd(yy, datediff(yy,0, getdate()), 0))))-1
--END  -- en if mes =1

	
WHILE @MesAux > 0 BEGIN

	SELECT @SaldoCte=(((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov not in 
										('Solicitud Cheque', 'Solicitud Deposito','Cancela Credilana','Cancela Prestamo','Seguro Vida',
										'Seguro Auto','Cancela Seg Auto','Cancela Seg Vida', 'Aplicacion Saldo','Aplicacion','Cobro','Cobro Instituciones') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) /*AND A.Modulo = 'CXC'*/ AND 
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())))) +


						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X--, cxcd D, cxc cx, cxcd XD
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Aplicacion','Cobro') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) /*AND A.Modulo = 'CXC' */AND 
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto')))  
										/*C.ID = D.id and D.Aplica = cx.Mov and d.AplicaId = cx.MovId and cx.id = XD.id and 
										XD.Aplica not in ('Seguro Vida','Seguro Auto'))) */+

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X, cxc Y, cxc Z--, cxcd D, cxc cx, cxcd XD
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Cobro Instituciones') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) /*AND A.Modulo = 'CXC' */AND 
										A.Aplica not in ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida', 'Complto Canc seg') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto')
										and x.origen = y.mov and x.origenid = y.movid and y.origen = z.mov and y.origenid = z.movid and
										z.mov not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) -
								
/**** se agrego el mov de engache para el saldo del cliente, funciona igual que el anticipo contado, etc, pero solo se consideraran
	cuando no se haya emitido la factura  *****/

					 ISNULL((	SELECT	SUM(A.Abono) 
								FROM	Auxiliar A, CxC, Venta VentaP, Condicion Cond
								WHERE	CxC.ID=A.ModuloID AND CxC.Mov IN ('Enganche', 'Anticipo Contado','Anticipo Mayoreo','Apartado') 
										AND CxC.Referencia= LTRIM(RTRIM(VentaP.Mov)) + ' ' + LTRIM(RTRIM(VentaP.MovID)) 
										AND CxC.Estatus='CONCLUIDO' /*AND A.Modulo = 'CXC'*/
										AND VentaP.Estatus not in('CANCELADO')
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))
										AND VentaP.Condicion=Cond.Condicion ), 0) +

/**** se agrego el mov de Devolucion Engache para el saldo del cliente, funciona igual que las demas devoluciones  *****/
							   
					(ISNULL((	SELECT	SUM(A.Cargo) 
								FROM	Auxiliar A, CxC 
								WHERE	CxC.ID=A.ModuloID/* AND A.Modulo = 'CXC'*/
										AND CxC.Mov IN ('Dev Anticipo Contado', 'Dev Anticipo Mayoreo', 'Devolucion Apartado', 'Devolucion Enganche')  
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))), 0)) )
-- Se acabaron las modificaciones del enganche 03

-------------------------------------------------------------------------------------------------------------
	SELECT @SaldoCte12=	(((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X, CXC Y
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov not in 
										('Solicitud Cheque', 'Solicitud Deposito','Cancela Credilana','Cancela Prestamo','Seguro Vida',
										'Seguro Auto','Cancela Seg Auto','Cancela Seg Vida', 'Aplicacion Saldo', 'Aplicacion','Cobro','Cobro Instituciones') AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) /*AND A.Modulo = 'CXC' */AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) AND A.Aplica NOT IN 
										('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida') 
										AND A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))))+

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X--, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Aplicacion','Cobro')  AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) /*AND A.Modulo = 'CXC'*/
										AND A.Aplica NOT IN ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida') AND
										A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) 
										/*C.ID = D.id and D.Aplica = cx.Mov and d.AplicaId = cx.MovId and cx.id = XD.id and 
										XD.Aplica not in ('Seguro Vida','Seguro Auto')))*/ +

						((		SELECT	isnull(sum(isnull(A.Cargo,0)) - sum(isnull(A.Abono,0)),0)
								FROM	Cxc C, Auxiliar A, CXC X, cxc Y, cxc Z--, cxcd D, cxc cx, cxcd XD 
								WHERE	A.ModuloID = C.ID AND C.EsCredilana in (0,null) AND C.Mov in ('Cobro Instituciones')  AND 
										A.Aplica = X.Mov AND A.AplicaID = X.MovID AND X.EsCredilana in (0,null) AND 
										(X.Mayor12Meses = 1 or C.Mayor12Meses = 1) /*AND A.Modulo = 'CXC'*/
										AND A.Aplica NOT IN ('Cancela Credilana','Cancela Prestamo','Cancela Seg Auto','Cancela Seg Vida') AND
										A.Fecha <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) 
										AND x.origen not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto')
										and x.origen = y.mov and x.origenid = y.movid and y.origen = z.mov and y.origenid = z.movid and
										z.mov not in ('Credilana','Prestamo','Seguro Vida','Seguro Auto'))) -

						ISNULL((SELECT	SUM(A.Abono) 
								FROM	Auxiliar A, CxC, Venta VentaP, Condicion Cond
								WHERE	CxC.ID=A.ModuloID AND CxC.Mov IN ('Enganche', 'Anticipo Contado', 'Anticipo Mayoreo', 'Apartado') 
										AND CxC.Referencia= LTRIM(RTRIM(VentaP.Mov)) + ' ' + LTRIM(RTRIM(VentaP.MovID)) 
										AND CxC.Estatus='CONCLUIDO' /*AND A.Modulo = 'CXC'*/
										AND VentaP.Estatus not in('CANCELADO')
										AND Cxc.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE()))
										AND VentaP.Condicion=Cond.Condicion AND 
										(ISNULL(Cond.DANumeroDocumentos, ISNULL(Cond.Meses, ( Cond.DiasVencimiento/30) )) > 12 )), 0) +


					(ISNULL	((	SELECT	SUM(A.Cargo) 
								FROM	Cxc X, Cxc C, Venta V, Condicion Cond, Auxiliar A  
								WHERE	C.Mov IN ('Dev Anticipo Contado', 'Dev Anticipo Mayoreo', 'Devolucion Apartado', 'Devolucion Enganche') 
										and ltrim(X.Mov) + ' ' +  ltrim(X.MovId) = C.RefAnticipoMAVI and ltrim(V.Mov) + ' ' +  ltrim(V.MovId) = X.Referencia
										AND V.Condicion=Cond.Condicion /*AND A.Modulo = 'CXC'*/ AND
										((ISNULL(Cond.DANumeroDocumentos,ISNULL(Cond.Meses,(Cond.DiasVencimiento/30))) > 12))
										and C.ID=A.ModuloID
										AND C.FechaEmision <= DATEADD(m, @mesantes, DATEADD(dd, -(DAY(GETDATE())), GETDATE())) ), 0)))


	SELECT @InteresesPorCobrar = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('110-99-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @Clientes= ISNULL(@SaldoCte,0) - ISNULL(@SaldoCte12,0) /*- ISNULL(@CredilanaPrestamo,0)*/ - ISNULL(@InteresesPorCobrar,0) 

	SELECT @Deudores= (SELECT SUM(ISNULL(D.Debe,0)) - SUM(ISNULL(D.Haber, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('112-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @ChequesDev = (SELECT SUM(ISNULL(D.Debe,0)) - SUM(ISNULL(D.Haber, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('103-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @BancosNac = (SELECT SUM(ISNULL(D.Debe,0)) - SUM(ISNULL(D.Haber, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('101-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @Inversiones = (SELECT SUM(ISNULL(D.Debe,0)) - SUM(ISNULL(D.Haber, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('104-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @SaldosAFavor = (SELECT SUM(ISNULL(D.Debe,0)) - SUM(ISNULL(D.Haber, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('116-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @Proveedores = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('203-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @Acreedores = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('206-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @IVAPorPagar = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('201-_1-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))


	SELECT @Documentos = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('202-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @Creditos = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('208-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @CreditosLP = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('210-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @InteresesD = (SELECT SUM(ISNULL(D.Haber,0)) - SUM(ISNULL(D.Debe, 0)) FROM Cont C, ContD D 
							WHERE C.Estatus='CONCLUIDO' AND	C.ID=D.ID AND D.Cuenta LIKE ('207-__-_____') 
							AND C.FechaEmision BETWEEN @FechaInicial 
							AND  DATEADD(mm, @mesantes, DATEADD(dd,-1,DATEADD(yy, DATEDIFF(yy,0, GETDATE()), 0))))

	SELECT @FactorAjuste =(SELECT Importe FROM TablaAnualD WHERE TablaAnual = 'INPC' AND Ejercicio = @anoaux 
							AND  Periodo = @mesaux )

	IF (@AjusteAntes <> 0) BEGIN
		SELECT @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD WHERE TablaAnual = 'INPC' AND Ejercicio = @anoaux 
							AND  Periodo = @ajusteantes )  END -- mes 1
	IF (@AjusteAntes = 0) BEGIN
		set @AjusteAntes=12
		select @FactorAjusteAntes =(SELECT Importe FROM TablaAnualD WHERE TablaAnual = 'INPC' AND Ejercicio = @anoaux -1
							AND  Periodo = @ajusteantes )  END

	SELECT @TotalCreditos= @Clientes + @Deudores + @ChequesDev + @BancosNac + @Inversiones + @SaldosAFavor
	SELECT @TotalDeudas= @Proveedores + @Acreedores +  @IVAPorPagar + @Documentos + @Creditos +@CreditosLP + @InteresesD 
	SELECT @Diferencia=@TotalCreditos - @TotalDeudas
	SELECT @FactorAjusteCalculado=(SELECT ROUND(CONVERT(float, SUBSTRING(CONVERT(char, @FactorAjuste / @FactorAjusteAntes -1), 1, 10)), 6))
	SELECT @Producto=@Diferencia * @FactorAjusteCalculado

	INSERT INTO @TablaAjusteAnual ( Ejercicio, Periodo, Clientes, Deudores, ChequesDevueltos, BancosNac, Inversiones, 
						SaldosAFavor, TotalCreditos, Proveedores, Acreedores, IVAPorPagar, Documentos, CreditosBan, 
						CreditosBanLP, InteresesDevengados, TotalDeudas, Diferencia, FactorAjuste, Producto ) 
		VALUES (@AnoAux, @MesAux, @Clientes, @Deudores, @ChequesDev, @BancosNac, @Inversiones, @SaldosAFavor, @TotalCreditos,
				@Proveedores, @Acreedores, @IVAPorPagar, @Documentos, @Creditos, @CreditosLP, @InteresesD, @TotalDeudas,
				@Diferencia, @FactorAjusteCalculado, @Producto) 

	SET @MesAux = @MesAux-1
	SET @MesAntes = @MesAntes -1 
	SET @AjusteAntes = @AjusteAntes -1 

END

END
*/

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos','Clientes', 
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Clientes FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual


INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'Deudores', 
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Deudores FROM @TablaAjusteAnual WHERE Periodo= 12),0), 
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'ChequesDevueltos', 
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT ChequesDevueltos FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'BancosNac', 
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT BancosNac FROM @TablaAjusteAnual WHERE Periodo= 12),0), 
	NULL
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'Inversiones', 
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Inversiones FROM @TablaAjusteAnual WHERE Periodo= 12),0), 
	NULL
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'SaldosAFavor', 
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT SaldosAFavor FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Creditos', 'TotalCreditos', 
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT TotalCreditos FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'Proveedores', 
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Proveedores FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'Acreedores', 
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Acreedores FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'IVAPorPagar', 
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT IVAPorPagar FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'Documentos', 
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Documentos FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'CreditosBan', 
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT CreditosBan FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'CreditosBanLP', 
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT CreditosBanLP FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'InteresesDevengados', 
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT InteresesDevengados FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Deudas', 'TotalDeudas', 
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT TotalDeudas FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Diferencia', 'Diferencia', 
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Diferencia FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Factor de Ajuste', 'FactorAjuste', 
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT FactorAjuste FROM @TablaAjusteAnual WHERE Periodo= 12),0), 
	NULL 
FROM @TablaAjusteAnual

INSERT INTO @TablaAjustePeriodo SELECT DISTINCT Ejercicio, 'Producto', 'Producto', 
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 1),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 2),0),
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 3),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 4),0), 
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 5),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 6),0), 
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 7),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 8),0),  
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 9),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 10),0),  
	ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 11),0), ISNULL((SELECT Producto FROM @TablaAjusteAnual WHERE Periodo= 12),0),
	NULL 
FROM @TablaAjusteAnual

IF (MONTH(GETDATE()) <> 1) BEGIN

	SELECT @INPC=(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual='INPC' AND Ejercicio=YEAR(GETDATE()) 
					AND Periodo=MONTH(GETDATE())-1)
	
	SELECT @INPC1=(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual='INPC' AND Ejercicio=YEAR(GETDATE()) - 1
					AND Periodo=12)
END

IF (MONTH(GETDATE()) = 1) BEGIN

	SELECT @INPC=(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual='INPC' AND Ejercicio=YEAR(GETDATE()) -1
					AND Periodo=12)
	
	SELECT @INPC1=(SELECT Importe FROM TablaAnualD With(NoLock) WHERE TablaAnual='INPC' AND Ejercicio=YEAR(GETDATE()) - 2
					AND Periodo=12)
END


UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				 ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				 ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Clientes' )
	WHERE Concepto='Clientes'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Deudores' )
	WHERE Concepto='Deudores'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='ChequesDevueltos' )
	WHERE Concepto='ChequesDevueltos'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='BancosNac' )
	WHERE Concepto='BancosNac' 
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Inversiones' )
	WHERE Concepto='Inversiones'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='SaldosAFavor' )
	WHERE Concepto='SaldosAFavor'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='TotalCreditos' )
	WHERE Concepto='TotalCreditos'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Proveedores' )
	WHERE Concepto='Proveedores'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Acreedores' )
	WHERE Concepto='Acreedores'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='IVAPorPagar' )
	WHERE Concepto='IVAPorPagar'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Documentos' )
	WHERE Concepto='Documentos'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='CreditosBan' )
	WHERE Concepto='CreditosBan'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='CreditosBanLP' )
	WHERE Concepto='CreditosBanLP'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='InteresesDevengados' )
	WHERE Concepto='InteresesDevengados'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='TotalDeudas' )
	WHERE Concepto='TotalDeudas'
UPDATE @TablaAjustePeriodo SET Total=(SELECT ISNULL(Periodo1,0) + ISNULL(Periodo2,0) + ISNULL(Periodo3,0) + ISNULL(Periodo4,0) + 
				ISNULL(Periodo5,0) + ISNULL(Periodo6,0) + ISNULL(Periodo7,0) + ISNULL(Periodo8,0) + ISNULL(Periodo9,0) + 
				ISNULL(Periodo10,0) + ISNULL(Periodo11,0) + ISNULL(Periodo12,0) FROM @TablaAjustePeriodo WHERE Concepto='Diferencia' )
	WHERE Concepto='Diferencia'

UPDATE @TablaAjustePeriodo SET Total= (SELECT ROUND(CONVERT(float, SUBSTRING(CONVERT(char, ISNULL(@INPC,0) / ISNULL(@INPC1,0) - 1 ), 1, 10)),6) )
	WHERE Concepto='FactorAjuste'

UPDATE @TablaAjustePeriodo SET Total=(SELECT Total From @TablaAjustePeriodo WHERE Concepto='Diferencia') * 
				(SELECT Total From @TablaAjustePeriodo WHERE Concepto='FactorAjuste') WHERE Concepto='Producto'


SELECT * FROM @TablaAjustePeriodo

-- exec ajusteanual

-- EXEC  spHistoricoMovimientoMAVI '1-12 Meses', '2009-03-09'
-- Exec sp_EspecificacionSaldosClientesMAVI 2009, 2

--select * from auxiliar
GO
