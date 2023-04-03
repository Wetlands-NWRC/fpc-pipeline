import os 
import click

from . import run

CONTEXT_SETTINGS = dict(
    default_map={
        'diag': {'out_dir': './output', 'data_dir': "./data", "target_var": 'VV', 'land_cover': None},
        }
)


@click.group(context_settings=CONTEXT_SETTINGS)
def cli():
    pass


@cli.command()
@click.option('--out_dir', default="./output")
@click.option('--data_dir', default='./data')
@click.option('--land_cover', default=None)
@click.option('--target_var', default='VV')
def diag(out_dir, data_dir, target_var, land_cover):
    click.echo("Running Diagnostics")
    out_dir = os.path.join(out_dir, target_var)
    if not os.path.exists(out_dir):
        os.makedirs(out_dir)

    runner = run.RunDiagCli(
        data_dir=data_dir,
        output_dir=out_dir,
        target_var=target_var,
        target_land_covers=land_cover
    )

    exit = runner.run()
    click.echo(f"Diagnostics has {'failed' if exit > 0 else 'completed'}, status code {exit}")