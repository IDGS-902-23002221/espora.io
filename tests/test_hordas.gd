extends GdUnitTestSuite

func test_total_y_ultima() -> void:
	assert_int(Hordas.total()).is_equal(GameConfig.HORDAS.size())
	assert_int(Hordas.ultima()).is_equal(Hordas.total() - 1)

func test_configuracion_valida_e_invalida() -> void:
	assert_bool(Hordas.es_valido(0)).is_true()
	assert_bool(Hordas.es_valido(Hordas.ultima())).is_true()
	assert_bool(Hordas.es_valido(-1)).is_false()
	assert_bool(Hordas.es_valido(Hordas.total())).is_false()
	assert_bool(Hordas.configuracion(Hordas.total()).is_empty()).is_true()

func test_configuracion_coincide_con_game_config() -> void:
	assert_float(Hordas.duracion(0)).is_equal_approx(float(GameConfig.HORDAS[0]["duracion"]), 0.0001)
	assert_float(float(Hordas.configuracion(0)["velocidad_npc"])).is_equal_approx(5.0, 0.0001)
	assert_int(int(Hordas.configuracion(0)["npc_por_horda"])).is_equal(12)

func test_estado_inicial() -> void:
	var hordas: Hordas = Hordas.new()
	assert_int(hordas.indice).is_equal(0)
	assert_bool(hordas.en_pausa).is_false()
	assert_bool(hordas.terminada).is_false()
	assert_float(hordas.tiempo_restante).is_equal_approx(Hordas.duracion(0), 0.0001)

func test_avance_parcial_no_emite_eventos() -> void:
	var hordas: Hordas = Hordas.new()
	var eventos: Array = hordas.avanzar_tiempo(10.0)
	assert_array(eventos).is_empty()
	assert_float(hordas.tiempo_restante).is_equal_approx(Hordas.duracion(0) - 10.0, 0.0001)
	assert_bool(hordas.en_pausa).is_false()

func test_fin_de_horda_entra_en_pausa() -> void:
	var hordas: Hordas = Hordas.new()
	var eventos: Array = hordas.avanzar_tiempo(Hordas.duracion(0))
	assert_array(eventos).has_size(1)
	assert_int(eventos[0]).is_equal(Hordas.Evento.FIN_HORDA)
	assert_bool(hordas.en_pausa).is_true()
	assert_float(hordas.tiempo_restante).is_equal_approx(GameConfig.PAUSA_ENTRE_HORDAS, 0.0001)
	assert_int(hordas.indice).is_equal(0)

func test_fin_de_pausa_inicia_la_siguiente() -> void:
	var hordas: Hordas = Hordas.new()
	hordas.avanzar_tiempo(Hordas.duracion(0))
	var eventos: Array = hordas.avanzar_tiempo(GameConfig.PAUSA_ENTRE_HORDAS)
	assert_array(eventos).has_size(1)
	assert_int(eventos[0]).is_equal(Hordas.Evento.INICIO_HORDA)
	assert_bool(hordas.en_pausa).is_false()
	assert_int(hordas.indice).is_equal(1)
	assert_float(hordas.tiempo_restante).is_equal_approx(Hordas.duracion(1), 0.0001)

func test_delta_grande_cruza_horda_y_pausa() -> void:
	var hordas: Hordas = Hordas.new()
	var eventos: Array = hordas.avanzar_tiempo(
		Hordas.duracion(0) + GameConfig.PAUSA_ENTRE_HORDAS
	)
	assert_array(eventos).has_size(2)
	assert_int(eventos[0]).is_equal(Hordas.Evento.FIN_HORDA)
	assert_int(eventos[1]).is_equal(Hordas.Evento.INICIO_HORDA)
	assert_int(hordas.indice).is_equal(1)
	assert_float(hordas.tiempo_restante).is_equal_approx(Hordas.duracion(1), 0.0001)

func test_fin_de_partida_tras_la_ultima_horda() -> void:
	var hordas: Hordas = Hordas.new()
	var pasos: int = 0
	var evento_final: int = Hordas.Evento.NADA
	# Cada llamada cierra un segmento (horda o pausa) al consumir su tiempo.
	while not hordas.terminada and pasos < 100:
		var eventos: Array = hordas.avanzar_tiempo(hordas.tiempo_restante)
		for evento in eventos:
			evento_final = int(evento)
		pasos += 1
	assert_bool(hordas.terminada).is_true()
	assert_int(evento_final).is_equal(Hordas.Evento.FIN_PARTIDA)
	assert_int(hordas.indice).is_equal(Hordas.ultima())

func test_tras_terminar_no_emite_mas() -> void:
	var hordas: Hordas = Hordas.new()
	while not hordas.terminada:
		hordas.avanzar_tiempo(hordas.tiempo_restante)
	assert_array(hordas.avanzar_tiempo(999.0)).is_empty()
	assert_bool(hordas.terminada).is_true()

func test_reiniciar_vuelve_al_inicio() -> void:
	var hordas: Hordas = Hordas.new()
	hordas.avanzar_tiempo(Hordas.duracion(0))
	hordas.avanzar_tiempo(GameConfig.PAUSA_ENTRE_HORDAS)
	hordas.reiniciar()
	assert_int(hordas.indice).is_equal(0)
	assert_bool(hordas.en_pausa).is_false()
	assert_bool(hordas.terminada).is_false()
	assert_float(hordas.tiempo_restante).is_equal_approx(Hordas.duracion(0), 0.0001)
