# Atajos del curso. `make` sin argumentos muestra la ayuda.
UV      ?= uv
S       ?= 1
SALIDA  := tmp/ejecutados

.PHONY: help setup sync lab sesion test clean

help: ## Muestra esta ayuda
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'
	@echo "  Variables: S=<n> (sesion), UV=<ruta a uv>"

setup: ## Instala uv si falta y prepara el entorno (.venv)
	./instalar.sh

sync: ## Sincroniza .venv con uv.lock (incluye JupyterLab)
	$(UV) sync --locked --group lab

lab: ## Abre JupyterLab en la carpeta del curso
	$(UV) run --locked --group lab jupyter lab

sesion: ## Abre JupyterLab directamente en una sesion: make sesion S=3
	$(UV) run --locked --group lab jupyter lab sesiones/sesion$(S)/s$(S).ipynb

test: ## Ejecuta todos los cuadernos de principio a fin (salida en tmp/, no toca los originales)
	@mkdir -p $(SALIDA)
	@for nb in sesiones/sesion*/s*.ipynb; do \
		echo ">> $$nb"; \
		start=$$(date +%s); \
		$(UV) run --locked --group lab jupyter nbconvert --to notebook --execute \
			--ExecutePreprocessor.timeout=900 --output-dir $(SALIDA) "$$nb" >/dev/null 2>$(SALIDA)/$$(basename $$nb .ipynb).log \
			&& echo "   OK ($$(( $$(date +%s) - start ))s)" \
			|| { echo "   FALLO, ver $(SALIDA)/$$(basename $$nb .ipynb).log"; fail=1; }; \
	done; exit $${fail:-0}

clean: ## Borra checkpoints, cachés y cuadernos ejecutados y salidas de ejercicios
	find . -name .ipynb_checkpoints -type d -prune -exec rm -rf {} +
	find . -name __pycache__ -type d -prune -exec rm -rf {} +
	rm -rf $(SALIDA) sesiones/*/salidas
